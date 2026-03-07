_base_ = [
    '../_base_/models/mask-rcnn_r50_fpn.py',
    '../_base_/datasets/planet_nearmap10075s_448.py',
    '../_base_/schedules/schedule_planet_100e.py',
    '../_base_/default_runtime_planet.py'
]

model = dict(
    type='PointRend',
    roi_head=dict(
        type='PointRendRoIHead',
        bbox_head=dict(
            type='Shared2FCBBoxHead',
            in_channels=256,
            fc_out_channels=1024,
            roi_feat_size=7,
            num_classes=1,
            bbox_coder=dict(
                type='DeltaXYWHBBoxCoder',
                target_means=[0., 0., 0., 0.],
                target_stds=[0.1, 0.1, 0.2, 0.2]),
            reg_class_agnostic=False,
            loss_cls=dict(
                type='CrossEntropyLoss', use_sigmoid=False, loss_weight=1.0),
            loss_bbox=dict(type='L1Loss', loss_weight=1.0)),
        mask_roi_extractor=dict(
            type='GenericRoIExtractor',
            aggregation='concat',
            roi_layer=dict(
                _delete_=True, type='SimpleRoIAlign', output_size=14),
            out_channels=256,
            featmap_strides=[4]),
        mask_head=dict(
            _delete_=True,
            type='CoarseMaskHead',
            num_fcs=2,
            in_channels=256,
            conv_out_channels=256,
            fc_out_channels=1024,
            num_classes=1,
            loss_mask=dict(
                type='CrossEntropyLoss', use_mask=True, loss_weight=1.0)),
        point_head=dict(
            type='MaskPointHead',
            num_fcs=3,
            in_channels=256,
            fc_channels=256,
            num_classes=1,
            coarse_pred_each_layer=True,
            loss_point=dict(
                type='CrossEntropyLoss', use_mask=True, loss_weight=1.0))),
    train_cfg=dict(
        rcnn=dict(
            mask_size=7,
            num_points=14 * 14,
            oversample_ratio=3,
            importance_sample_ratio=0.75)),
    test_cfg=dict(
        rcnn=dict(
            subdivision_steps=5,
            subdivision_num_points=28 * 28,
            scale_factor=2)))
