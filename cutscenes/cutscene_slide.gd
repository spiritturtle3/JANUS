class_name CutsceneSlide
extends Resource

@export var texture: Texture2D
@export var duration: float = 0.0  # seconds before moving on automatically; 0 = wait for a click
@export var if_level: int = 0   # 0 = always show; otherwise the level whose choice decides
@export var if_choice: int = 0  # show only if that level's choice equals this (0 = left, 1 = right)
