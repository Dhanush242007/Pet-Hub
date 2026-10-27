import 'package:flutter/material.dart';

import '../models/pet.dart';
import 'pet_avatar.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final String? extraLine;

  const PetCard({super.key, required this.pet, this.onTap, this.extraLine});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PetAvatar(photoUrl: pet.photoUrl, emoji: pet.emoji, radius: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                        '${pet.petType} • ${(pet.breed == null || pet.breed!.isEmpty) ? 'Unknown breed' : pet.breed}'),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(pet.registrationId,
                          style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                    if (extraLine != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(extraLine!),
                      ),
                  ],
                ),
              ),
              if (pet.isLost)
                Chip(
                  label: Text('LOST',
                      style: TextStyle(
                          color: scheme.onErrorContainer, fontSize: 11)),
                  backgroundColor: scheme.errorContainer,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}