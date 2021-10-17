package common;

class EntityManager {
  public static var entities: haxe.ds.Map<String, Entity> = [];

  public static function registerEntity(id: String, e: Entity) {
    if (entities.exists(id)) {
      throw "Entity exists: " + id;
      return;
    }
    entities[id] = e;
  }

  public static function calculationUpdate(dt: Float) {
    for (entity in entities) {
      entity.calculationUpdate(dt);
    }
  }

  public static function update(dt: Float) {
    for (entity in entities) {
      entity.update(dt);
    }
  }
}
