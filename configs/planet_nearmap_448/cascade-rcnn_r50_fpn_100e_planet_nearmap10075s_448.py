_base_ = [
    '../_base_/models/cascade-rcnn_r50_fpn.py',
    '../_base_/datasets/planet_nearmap10075s_448.py',
    '../_base_/schedules/schedule_planet_100e.py',
    '../_base_/default_runtime_planet.py'
]

model = dict(
    roi_head=dict(bbox_head=[
        dict(num_classes=1),
        dict(num_classes=1),
        dict(num_classes=1),
    ]))

# Cascade R-CNN has no mask head; evaluate bounding boxes only.
val_evaluator = dict(metric='bbox')
test_evaluator = dict(metric='bbox')
