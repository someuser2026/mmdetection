_base_ = [
    '../_base_/models/retinanet_r50_fpn.py',
    '../_base_/datasets/planet_nearmap10075s_448.py',
    '../_base_/schedules/schedule_planet_100e.py',
    '../_base_/default_runtime_planet.py'
]

model = dict(
    bbox_head=dict(
        type='RetinaHead',
        num_classes=1,
        in_channels=256,
        stacked_convs=4,
        feat_channels=256,
        anchor_generator=dict(
            type='AnchorGenerator',
            octave_base_scale=4,
            scales_per_octave=3,
            ratios=[0.5, 1.0, 2.0],
            strides=[8, 16, 32, 64, 128]),
        bbox_coder=dict(
            type='DeltaXYWHBBoxCoder',
            target_means=[.0, .0, .0, .0],
            target_stds=[1.0, 1.0, 1.0, 1.0]),
        loss_cls=dict(
            type='FocalLoss',
            use_sigmoid=True,
            gamma=2.0,
            alpha=0.25,
            loss_weight=1.0),
        loss_bbox=dict(type='L1Loss', loss_weight=1.0)),
)

# RetinaNet is a bbox-only detector.
val_evaluator = dict(metric='bbox')
test_evaluator = dict(metric='bbox')
