import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHealerCardSkeleton extends StatelessWidget {
  const ShimmerHealerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image placeholder
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // text placeholders
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 12.0, bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title line
                    Container(height: 16, width: double.infinity, decoration: _decoration()),
                    const SizedBox(height: 8),
                    // subtitle line 1
                    Container(height: 12, width: double.infinity, decoration: _decoration()),
                    const SizedBox(height: 6),
                    // subtitle line 2 (shorter)
                    Container(height: 12, width: MediaQuery.of(context).size.width * 0.4, decoration: _decoration()),
                    const Spacer(),
                    // location row
                    Row(
                      children: [
                        Container(height: 12, width: 12, decoration: _circleDecoration()),
                        const SizedBox(width: 6),
                        Expanded(child: Container(height: 12, decoration: _decoration())),
                        const SizedBox(width: 8),
                        Container(height: 12, width: 12, decoration: _circleDecoration()),
                        const SizedBox(width: 6),
                        Container(height: 12, width: 60, decoration: _decoration()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _decoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      );

  BoxDecoration _circleDecoration() => const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      );
}
