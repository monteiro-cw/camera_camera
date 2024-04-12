import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_status.dart';
import 'package:camera_camera/src/shared/entities/camera_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraCameraPreview extends StatefulWidget {
  final void Function(String value)? onFile;
  final CameraCameraController controller;
  final bool enableZoom;
  final Widget? rightWidget;
  final Widget? content;
  CameraCameraPreview({
    Key? key,
    this.onFile,
    required this.controller,
    required this.enableZoom,
    this.rightWidget,
    this.content,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {
  @override
  void initState() {
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<CameraCameraStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) => status.when(
          success: (camera) => GestureDetector(
                onScaleUpdate: (details) {
                  widget.controller.setZoomLevel(details.scale);
                },
                child: Container(
                  height: size.height,
                  width: size.width,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: widget.controller.cameraMode.value,
                      child: Stack(
                        children: [
                          widget.controller.buildPreview(),
                          Column(
                            children: [
                              Expanded(
                                child: widget.content ?? SizedBox.shrink(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    if (widget.controller.flashModes.length > 1)
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Colors.black.withOpacity(0.6),
                                        child: IconButton(
                                          onPressed: () {
                                            widget.controller.changeFlashMode();
                                          },
                                          icon: Icon(
                                            camera.flashModeIcon,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    Spacer(),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          widget.controller.takePhoto();
                                        },
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    widget.rightWidget ?? SizedBox.shrink()
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          failure: (message, _) => Container(
                color: Colors.black,
                child: Text(message),
              ),
          orElse: () => Container(
                color: Colors.black,
              )),
    );
  }

  Map<DeviceOrientation, int> turns = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeRight: 1,
    DeviceOrientation.portraitDown: 2,
    DeviceOrientation.landscapeLeft: 3,
  };
}
