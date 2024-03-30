import Text "mo:base/Text";
module {
  public type Color = Text;

  public let defaultBg = "#EEEEEE";

  public func validate(color : Color, default : Color) : Color {
    // TODO: check if color is allowed
    if (Text.size(color) > 12) return default;
    return color;
  };
};
