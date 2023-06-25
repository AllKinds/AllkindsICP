module {
  public type Color = Text;

  public let defaultBg = "#EEEEEE";

  public func validate(color : Color, default : Color) : Color {
    // TODO: check if color is allowed
    return color;
  };
};
