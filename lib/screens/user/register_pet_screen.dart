import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/pet.dart';
import '../../services/error_helper.dart';
import '../../services/pet_service.dart';
import '../../services/photo_service.dart';
import '../../widgets/option_dropdown.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/photo_sheet.dart';

class RegisterPetScreen extends StatefulWidget {
  final Pet? pet; // null = register new, not null = edit
  const RegisterPetScreen({super.key, this.pet});

  @override
  State<RegisterPetScreen> createState() => _RegisterPetScreenState();
}

class _RegisterPetScreenState extends State<RegisterPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _type = 'Dog';
  String _gender = 'Male';
  String _vacc = 'Not Vaccinated';
  bool _saving = false;

  // Photo state
  XFile? _newPhoto;
  Uint8List? _previewBytes;
  bool _removePhoto = false;

  bool get _isEdit => widget.pet != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    if (p != null) {
      _nameCtrl.text = p.name;
      _breedCtrl.text = p.breed ?? '';
      _ageCtrl.text = p.ageYears?.toString() ?? '';
      _colorCtrl.text = p.color ?? '';
      _phoneCtrl.text = p.ownerPhone;
      _cityCtrl.text = p.city ?? '';
      _type = p.petType;
      _gender = p.gender;
      _vacc = p.vaccinationStatus;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _colorCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  String _cleanPhone(String v) => v.replaceAll(RegExp(r'[\s-]'), '');
  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _choosePhoto() async {
    if (_saving) return;
    final existing = widget.pet?.photoUrl;
    final hasPhoto =
        _previewBytes != null || (existing != null && !_removePhoto);
    try {
      final action = await showPhotoSheet(context, hasPhoto: hasPhoto);
      if (action == null) return;
      if (action.remove) {
        setState(() {
          _newPhoto = null;
          _previewBytes = null;
          _removePhoto = true;
        });
        return;
      }
      final bytes = await action.file!.readAsBytes();
      if (!mounted) return;
      setState(() {
        _newPhoto = action.file;
        _previewBytes = bytes;
        _removePhoto = false;
      });
    } catch (_) {
      _snack('Could not open the photo picker.');
    }
  }

  Widget _photoPicker() {
    final scheme = Theme.of(context).colorScheme;
    final existing = widget.pet?.photoUrl;

    Widget avatar;
    if (_previewBytes != null) {
      avatar = CircleAvatar(
          radius: 52, backgroundImage: MemoryImage(_previewBytes!));
    } else if (existing != null && !_removePhoto) {
      avatar = PetAvatar(photoUrl: existing, emoji: '🐾', radius: 52);
    } else {
      avatar = CircleAvatar(
        radius: 52,
        backgroundColor: scheme.primaryContainer,
        child: Icon(Icons.add_a_photo, size: 36, color: scheme.primary),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _choosePhoto,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              avatar,
              CircleAvatar(
                radius: 17,
                backgroundColor: scheme.primary,
                child:
                    const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Pet photo (optional)'),
      ],
    );
  }

  Future<void> _save() async {
    if (_saving) return; // blocks double taps
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'pet_type': _type,
      'breed': _emptyToNull(_breedCtrl.text),
      'age_years':
          _ageCtrl.text.trim().isEmpty ? null : int.parse(_ageCtrl.text.trim()),
      'gender': _gender,
      'color': _emptyToNull(_colorCtrl.text),
      'owner_phone': _cleanPhone(_phoneCtrl.text),
      'city': _emptyToNull(_cityCtrl.text),
      'vaccination_status': _vacc,
    };

    final petService = PetService();
    final photos = PhotoService();

    try {
      String message;
      final String petId;
      final String? oldUrl = widget.pet?.photoUrl;

      if (_isEdit) {
        petId = widget.pet!.id;
        await petService.updatePet(petId, data);
        message = 'Pet updated successfully';
      } else {
        final pet = await petService.addPet(data);
        petId = pet.id;
        message = 'Pet registered! Pet ID: ${pet.registrationId}';
      }

      // Photo step (the pet itself is already saved at this point)
      try {
        if (_newPhoto != null) {
          final url = await photos.upload(petId, _newPhoto!);
          await petService.updatePet(petId, {'photo_url': url});
          await photos.deleteByUrl(oldUrl);
        } else if (_removePhoto && oldUrl != null) {
          await petService.updatePet(petId, {'photo_url': null});
          await photos.deleteByUrl(oldUrl);
        }
      } catch (e) {
        message = 'Pet saved, but the photo failed: ${friendlyError(e)}';
      }

      if (!mounted) return;
      _snack(message);
      Navigator.of(context).pop(true);
    } catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Pet' : 'Register Pet')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _photoPicker(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Pet name *',
                          prefixIcon: Icon(Icons.pets)),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter the pet name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    OptionDropdown(
                      label: 'Pet type *',
                      options: Pet.types,
                      value: _type,
                      onChanged: (v) => _type = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _breedCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Breed',
                          prefixIcon: Icon(Icons.category_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Age (years)',
                          prefixIcon: Icon(Icons.cake_outlined)),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return null;
                        final n = int.tryParse(t);
                        if (n == null || n < 0 || n > 50) {
                          return 'Enter a whole number from 0 to 50';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    OptionDropdown(
                      label: 'Gender *',
                      options: Pet.genders,
                      value: _gender,
                      onChanged: (v) => _gender = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _colorCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Color',
                          prefixIcon: Icon(Icons.palette_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Owner contact number *',
                          prefixIcon: Icon(Icons.phone_outlined)),
                      validator: (v) {
                        final t = _cleanPhone(v ?? '');
                        if (t.isEmpty) return 'Enter a contact number';
                        if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(t)) {
                          return 'Enter 10 to 13 digits (e.g. 9876543210)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city_outlined)),
                    ),
                    const SizedBox(height: 16),
                    OptionDropdown(
                      label: 'Vaccination status *',
                      options: Pet.vaccStatuses,
                      value: _vacc,
                      onChanged: (v) => _vacc = v,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.5))
                            : Text(_isEdit ? 'Save Changes' : 'Register Pet'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}