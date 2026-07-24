import 'package:flutter/material.dart';

// CustomPainter lets us draw directly on the canvas, pixel by pixel.
// This is the "magic" behind Shadow Diary — everything here is just
// shapes and math reacting to one number: sunX.
class RoomScenePainter extends CustomPainter {
  // sunX ranges from 0.0 (far left = low mood) to 1.0 (far right = good mood)
  final double sunX;

  RoomScenePainter({required this.sunX});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background — interpolate between a moody dark blue and a warm gold
    //    based on sunX. Color.lerp does the blending math for us.
    final backgroundColor = Color.lerp(
      const Color(0xFF2B2D5C), // low mood: cool, dark
      const Color(0xFFFFD59E), // good mood: warm, bright
      sunX,
    )!;
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // 2. Floor — a slightly darker strip along the bottom third.
    final floorHeight = size.height * 0.3;
    final floorRect = Rect.fromLTWH(
      0,
      size.height - floorHeight,
      size.width,
      floorHeight,
    );
    final floorPaint = Paint()..color = backgroundColor.withOpacity(0.7);
    canvas.drawRect(floorRect, floorPaint);

    // 3. The object — a simple rounded block sitting in the middle of the floor.
    final objectWidth = size.width * 0.14;
    final objectHeight = size.height * 0.14;
    final objectCenterX = size.width / 2;
    final objectTop = size.height - floorHeight - objectHeight + 10;

    final objectRect = Rect.fromLTWH(
      objectCenterX - objectWidth / 2,
      objectTop,
      objectWidth,
      objectHeight,
    );
    final objectRRect = RRect.fromRectAndRadius(objectRect, const Radius.circular(10));
    final objectPaint = Paint()..color = const Color(0xFF3D3D3D);

    // 4. The shadow — THIS is the core "reacts to mood" effect.
    //    - How far sunX is from center (0.5) controls how long the shadow is.
    //    - Which side the sun is on controls which direction the shadow falls.
    final distanceFromCenter = sunX - 0.5; // -0.5 (far left) to 0.5 (far right)
    final shadowLength = objectWidth * (1.2 + distanceFromCenter.abs() * 4);
    final shadowShift = -distanceFromCenter * size.width * 0.35;

    final shadowRect = Rect.fromCenter(
      center: Offset(objectCenterX + shadowShift, objectTop + objectHeight + 6),
      width: shadowLength,
      height: objectHeight * 0.35,
    );
    // Shadow is darker and more solid on "low mood" days, soft and faint
    // on "good mood" days — same lerp trick as the background.
    final shadowOpacity = 0.55 - (sunX * 0.35);
    final shadowPaint = Paint()..color = Colors.black.withOpacity(shadowOpacity.clamp(0.1, 0.55));
    canvas.drawOval(shadowRect, shadowPaint);

    // Draw the object on top of its shadow.
    canvas.drawRRect(objectRRect, objectPaint);
  }

  @override
  bool shouldRepaint(covariant RoomScenePainter oldDelegate) {
    // Only repaint when sunX actually changes — keeps things efficient.
    return oldDelegate.sunX != sunX;
  }
}