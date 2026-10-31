import 'package:material_ui/material_ui.dart';

/// Скролл с «резиной» по краям, но без инерции: страница тянется за пальцем
/// и останавливается там, где её отпустили. За пределы можно оттянуть, обратно
/// возвращает мягкая пружина — это часть резины, а не разгон.
///
/// Отличие от [BouncingScrollPhysics]: после отпускания внутри диапазона
/// прокрутка не продолжает движение по инерции.
class ElasticScrollPhysics extends BouncingScrollPhysics {
  const ElasticScrollPhysics({super.parent});

  @override
  ElasticScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      ElasticScrollPhysics(parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Внутри диапазона — стоп на месте.
    if (!position.outOfRange) return null;
    // За краем — пружина возвращает обратно, скорость гасим.
    return super.createBallisticSimulation(
      position,
      velocity.clamp(-400.0, 400.0) * 0.35,
    );
  }
}
