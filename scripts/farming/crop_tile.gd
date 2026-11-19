# 萝卜农田逻辑原型；尚未接入地图、背包、时间、存档，未经过引擎运行验证。
class_name CropTile
extends Node2D

signal changed

enum Stage { EMPTY, SEED, GROWING, MATURE }

var tilled: bool = false
var watered: bool = false
var growth_days: int = 0
var stage: Stage = Stage.EMPTY

func hoe() -> bool:
    if tilled:
        return false
    tilled = true
    changed.emit()
    return true

func plant() -> bool:
    if not tilled or stage != Stage.EMPTY:
        return false
    growth_days = 0
    stage = Stage.SEED
    changed.emit()
    return true

func water() -> bool:
    if not tilled or watered:
        return false
    watered = true
    changed.emit()
    return true

# 时间系统每次过夜只调用一次；未浇水暂停生长。
func advance_day() -> void:
    if watered and stage != Stage.EMPTY:
        growth_days = mini(growth_days + 1, 4)
        if growth_days >= 4:
            stage = Stage.MATURE
        elif growth_days >= 2:
            stage = Stage.GROWING
    watered = false
    changed.emit()

# 交互层先检查背包容量，同步完成入包和清空；中途不允许 await。
func harvest() -> bool:
    if stage != Stage.MATURE:
        return false
    stage = Stage.EMPTY
    growth_days = 0
    changed.emit()
    return true
