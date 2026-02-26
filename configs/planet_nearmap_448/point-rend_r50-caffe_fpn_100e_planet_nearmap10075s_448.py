_base_ = [
    '../point_rend/point-rend_r50-caffe_fpn_ms-1x_coco.py',
    '../_base_/datasets/planet_nearmap10075s_448.py',
    '../_base_/schedules/schedule_planet_100e.py',
    '../_base_/default_runtime_planet.py'
]

model = dict(
    roi_head=dict(
        bbox_head=dict(num_classes=1),
        mask_head=dict(num_classes=1),
        point_head=dict(num_classes=1)))
