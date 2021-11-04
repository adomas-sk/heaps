package entities;

class Resources {
  public static var resources: Array<ResourceBundle> = [];

  public static function addResourceBundle(resourceBundle: ResourceBundle) {
    resources.push(resourceBundle);
  }

  public static function removeResourceBundle(resourceBundle: ResourceBundle) {
    resources.remove(resourceBundle);
  }
}
