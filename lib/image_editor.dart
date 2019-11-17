import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:image_crop/image_crop.dart';
import 'content_aware_scaler.dart';
import 'package:image_crop/image_crop.dart' as crop;

class ImageEditor extends StatefulWidget {

  final File image;

  ImageEditor(this.image);

  @override
  ImageEditorState createState() => ImageEditorState(image);
}

class ImageEditorState extends State<ImageEditor> {

  bool isSmartCropPage = true;
  bool isEnergyPage = false;
  bool isCropPage = false;
  bool isBlockPage = false;

  Widget smartCropPage;
  Widget energyPage;
  Widget cropPage;
  Widget blockPage;

  ContentAwareScaler contentAwareScaler;
  File image;

  ImageEditorState(this.image) {
    contentAwareScaler = ContentAwareScaler(image);

    smartCropPage = SmartCrop(contentAwareScaler);
    energyPage = Energy(contentAwareScaler);
    cropPage = Crop(contentAwareScaler);
    blockPage = Block(contentAwareScaler);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        title: Center(child: Text(widget.image.path.substring(widget.image.path.lastIndexOf("/") + 1))),
        backgroundColor: Colors.transparent,
        leading: GestureDetector(child: Icon(Icons.close, color: Colors.white,), onTap: () {Navigator.of(context).pop();},),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 20,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Center(
                child: Text("EDITOR", style: TextStyle(fontSize: 11),),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                child: currentPage(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    revertDialog();
                  },
                  child: Text(
                    "Revert",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        child: miniButton(Icons.content_cut, isSmartCropPage),
                        onTap: () {
                          setState(() {
                            isSmartCropPage = true;
                            isEnergyPage = false;
                            isCropPage = false;
                            isBlockPage = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: miniButton(Icons.lightbulb_outline, isEnergyPage),
                        onTap: () {
                          setState(() {
                            isSmartCropPage = false;
                            isEnergyPage = true;
                            isCropPage = false;
                            isBlockPage = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: miniButton(Icons.crop, isCropPage),
                        onTap: () {
                          setState(() {
                            isSmartCropPage = false;
                            isEnergyPage = false;
                            isCropPage = true;
                            isBlockPage = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: miniButton(Icons.pages, isBlockPage),
                        onTap: () {
                          setState(() {
                            isSmartCropPage = false;
                            isEnergyPage = false;
                            isCropPage = false;
                            isBlockPage = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 50,
          )
        ],
      ),
    );
  }

  Widget currentPage() {
    if (isSmartCropPage) {
      return smartCropPage;
    }
    if (isEnergyPage) {
      return energyPage;
    }
    if (isCropPage) {
      return cropPage;
    }
    if (isBlockPage) {
      return blockPage;
    }
  }

  Widget miniButton(IconData icon, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent[200]],
              begin: Alignment(0, 1),
              end: Alignment(0, -1),
            ),
            borderRadius: BorderRadius.circular(6)
          ),
          child: Icon(icon, color: Colors.white,),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? Colors.white : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  void revertDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(child: Text("Revert To Original Image?")),
          content: Container(
            width: 150,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8)
            ),
            child: FlatButton(
              child: Center(child: Text('Yes', style: TextStyle(color: Colors.white),)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  contentAwareScaler.changeImage(image);
                  (smartCropPage as SmartCrop).state.sameImage = false;
                  (smartCropPage as SmartCrop).state.setState((){});
                  setState(() {

                  });
                });
              },
            ),
          ),
        );
      },
    );
  }

}

Widget selectionButton(IconData icon, bool selected) {
  return Container(
    height: 50,
    width: 50,
    decoration: selected ? BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.lightBlue[600],
    ) : BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.lightBlue[600],
        width: 3.0,
      )
    ),
    child: Center(
      child: Container(
        child: Icon(icon, size: 30,),
      ),
    ),
  );
}


// Page 1
class SmartCrop extends StatefulWidget {

  final ContentAwareScaler contentAwareScaler;

  SmartCrop(this.contentAwareScaler);

  SmartCropState state;

  @override
  SmartCropState createState() => state = SmartCropState(contentAwareScaler.height(), contentAwareScaler.width());
}

class SmartCropState extends State<SmartCrop> {

  bool isLoading = false;

  int height;
  int width;

  Image image;
  bool sameImage = false;


  SmartCropState(this.height, this.width);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              sameImage ? image : FutureBuilder<Image>(
                future: widget.contentAwareScaler.getImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    image = snapshot.data;
                    precacheImage(image.image, context).then((v) {
                      sameImage = true;
                    });
                    return snapshot.data;
                  }
                  return Center(child: Text("Loading Image..."));
                },
              ),
              isLoading ? Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Container(height: 10,),
                      Text("Calculating", style: TextStyle(fontSize: 18),),
                    ],
                  ),
                ),
              ) : Container(),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           GestureDetector(
             child: Tooltip(
               message: "Smooth",
               child: selectionButton(Icons.memory, widget.contentAwareScaler.recalculate),
             ),
             onTap: () {
               if (widget.contentAwareScaler.recalculate != true) {
                 setState(() {
                   widget.contentAwareScaler.recalculate = true;
                 });
               }
             },
           ),
           Container(
             width: 30,
           ),
           GestureDetector(
             child: Tooltip(
               message: "Quick",
               child: selectionButton(Icons.av_timer, !widget.contentAwareScaler.recalculate),
             ),
             onTap: () {
               if (widget.contentAwareScaler.recalculate != false) {
                 setState(() {
                   widget.contentAwareScaler.recalculate = false;
                 });
               }
             },
           ),
         ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2
                      )
                  ),
                  child: Center(
                    child: Text(height.toString()),
                  )
              ),
              Expanded(
                child: Slider(
                  value: height == null ? (height = widget.contentAwareScaler.height()).roundToDouble() : height.roundToDouble(),
                  min: 1,
                  max: widget.contentAwareScaler.maxHeight.roundToDouble(),
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white70,
                  onChanged: (double val) {
                    if (val <= widget.contentAwareScaler.height()) {
                      setState(() {
                        height = val.round();
                      });
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  int numToRemove = (widget.contentAwareScaler.height() - height);
                  setState(() {
                    isLoading = true;
                  });
                  widget.contentAwareScaler.removecache = numToRemove;
                  compute(removeHorizontalSeams, widget.contentAwareScaler).then((v) {
                    widget.contentAwareScaler.picture = v.picture;
                    widget.contentAwareScaler.energy = v.energy;
                    setState(() {
                      isLoading = false;
                      sameImage = false;
                    });
                  });
                },
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Center(child: Text("Height"),),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2
                      )
                  ),
                  child: Center(
                    child: Text(width.toString()),
                  )
              ),
              Expanded(
                child: Slider(
                  value: width == null ? (width = widget.contentAwareScaler.width()).roundToDouble() : width.roundToDouble(),
                  min: 0,
                  max: widget.contentAwareScaler.maxWidth.roundToDouble(),
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white70,
                  onChanged: (double val) {
                    if (val <= widget.contentAwareScaler.width()) {
                      setState(() {
                        width = val.round();
                      });
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  int numToRemove = (widget.contentAwareScaler.width() - width);
                  setState(() {
                    isLoading = true;
                  });
                  widget.contentAwareScaler.removecache = numToRemove;
                  compute(removeVerticalSeams, widget.contentAwareScaler).then((v) {
                    widget.contentAwareScaler.picture = v.picture;
                    widget.contentAwareScaler.energy = v.energy;
                    setState(() {
                      isLoading = false;
                      sameImage = false;
                    });
                  });
                },
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Center(child: Text("Width"),),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static ContentAwareScaler removeHorizontalSeams(ContentAwareScaler scaler) {
    for (int i = 0; i < scaler.removecache; i++) {
      scaler.removeHorizontalSeam(scaler.findHorizontalSeam());
    }
    return scaler;
  }

  static ContentAwareScaler removeVerticalSeams(ContentAwareScaler scaler) {
    for (int i = 0; i < scaler.removecache; i++) {
      scaler.removeVerticalSeam(scaler.findVerticalSeam());
    }
    return scaler;
  }

}


// Page 2
class Energy extends StatefulWidget {

  ContentAwareScaler scaler;

  Energy(this.scaler);

  @override
  EnergyState createState() => EnergyState();
}

class EnergyState extends State<Energy> {

  int numSeams = 0;
  bool sameImage = false;
  bool isLoading = false;
  Image image;
  Image newImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              sameImage ? image : FutureBuilder<void>(
                future: precacheImage((newImage = widget.scaler.energyImage(0)).image, context).whenComplete(() {sameImage = true; image = newImage; setState(() {});}),
                builder: (context, snapshot) {
                  return Center(child: Text("Loading Image..."));
                },
              ),
              isLoading ? Container(
                decoration: BoxDecoration(
                    color: Colors.black45,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Container(height: 10,),
                      Text("Calculating", style: TextStyle(fontSize: 18),),
                    ],
                  ),
                ),
              ) : Container(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                child: Tooltip(
                  message: "Gradient",
                  child: selectionButton(Icons.gradient, widget.scaler.isDgr),
                ),
                onTap: () {
                  setState(() {
                    widget.scaler.setEnergyFunction(true, false, false);
                    image = widget.scaler.energyImage(0);
                  });
                },
              ),
              GestureDetector(
                child: Tooltip(
                  message: "Soft Edge",
                  child: selectionButton(Icons.border_clear, widget.scaler.isGaussianSobel),
                ),
                onTap: () {
                  setState(() {
                    widget.scaler.setEnergyFunction(false, true, false);
                    image = widget.scaler.energyImage(0);
                  });
                },
              ),
              GestureDetector(
                child: Tooltip(
                  message: "Hard Edge",
                  child: selectionButton(Icons.border_all, widget.scaler.isSobel),
                ),
                onTap: () {
                  setState(() {
                    widget.scaler.setEnergyFunction(false, false, true);
                    image = widget.scaler.energyImage(0);
                  });
                },
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3.0)
                ),
                child: Center(
                  child: Text(numSeams.toString()),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Slider(
                  value: numSeams.roundToDouble(),
                  min: 0,
                  max: 50,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white70,
                  onChanged: (double val) {
                    numSeams = val.round();
                    setState(() {});
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  widget.scaler.showSeams = numSeams;
                  compute(seamOverlay, widget.scaler).then((v) {
                    newImage = v;
                    setState(() {
                      isLoading = false;
                      sameImage = false;
                    });
                    precacheImage(image.image, context).then((v) {
                      image = newImage;
                      sameImage = true;
                    });
                  });
                },
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Center(child: Text("Show"),),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Image seamOverlay(ContentAwareScaler scaler) {
    return scaler.energyImage(scaler.showSeams);
  }

}




// Page 3
class Crop extends StatefulWidget {

  ContentAwareScaler contentAwareScaler;

  Crop(this.contentAwareScaler);

  @override
  CropState createState() => CropState();
}

class CropState extends State<Crop> {

  final cropKey = GlobalKey<crop.CropState>();

  double calculateHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 24;
    double ratio = widget.contentAwareScaler.height().roundToDouble() / widget.contentAwareScaler.width();
    return width * ratio;
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Container(
              height: calculateHeight(context),
              child: crop.Crop(
                key: cropKey,
                image: widget.contentAwareScaler.getImageSync().image,
                aspectRatio: widget.contentAwareScaler.width() / widget.contentAwareScaler.height(),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: GestureDetector(
            onTap: () {
              widget.contentAwareScaler.editedImageFile().then((file) {
                crop.ImageCrop.cropImage(
                  area: cropKey.currentState.area,
                  file: file,
                ).then((file) {
                  setState(() {
                    widget.contentAwareScaler.changeImage(file);
                  });
                });
              });
            },
            child: Container(
              height: 40,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue
              ),
              child: Center(
                child: Text(
                  "Crop Image",
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}




// Page 4
class Block extends StatefulWidget {

  ContentAwareScaler scaler;

  Block(this.scaler);

  @override
  BlockState createState() => BlockState();
}

class BlockState extends State<Block> {

  int xPos = 0;
  int yPos = 0;
  int width = 0;
  int height = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: widget.scaler.blockImage(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                child: boxControl(xPos, "X Pos"),
                onTap: () {
                  valueDialog("X Position", xPos, 0, widget.scaler.width() - width - 1,).then((newVal) {
                    setState(() {
                      xPos = newVal;
                      widget.scaler.setBlock(xPos, width, yPos, height);
                    });
                  });
                },
              ),
              GestureDetector(
                child: boxControl(yPos, "Y Pos"),
                onTap: () {
                  valueDialog("Y Position", yPos, 0, widget.scaler.height() - height - 1).then((newVal) {
                    setState(() {
                      yPos = newVal;
                      widget.scaler.setBlock(xPos, width, yPos, height);
                    });
                  });
                },
              ),
              GestureDetector(
                child: boxControl(width, "Width"),
                onTap: () {
                  valueDialog("Width", width, 0, widget.scaler.width() - xPos - 1).then((newVal) {
                    setState(() {
                      width = newVal;
                      widget.scaler.setBlock(xPos, width, yPos, height);
                    });
                  });
                },
              ),
              GestureDetector(
                child: boxControl(height, "Height"),
                onTap: () {
                  valueDialog("Height", height, 0, widget.scaler.height() - yPos - 1).then((newVal) {
                    setState(() {
                      height = newVal;
                      widget.scaler.setBlock(xPos, width, yPos, height);
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget boxControl(int value, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue,
                  width: 2
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Center(
                  child: Text(value.toString()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> valueDialog(String valName, int num, int min, int max) async {
    return await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ValueSliderDialog(valName, num, min, max);
      },
    );
  }

}

class ValueSliderDialog extends StatefulWidget {

  String valName;
  int num, min, max;

  ValueSliderDialog(this.valName, this.num, this.min, this.max);

  @override
  State createState() => ValueSliderDialogState();

}

class ValueSliderDialogState extends State<ValueSliderDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(child: Text(widget.valName)),
      content: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(
              child: Slider(
                value: widget.num.roundToDouble(),
                min: widget.min.roundToDouble(),
                max: widget.max.roundToDouble(),
                activeColor: Colors.blue,
                inactiveColor: Colors.white70,
                onChanged: (val) {
                  setState(() {
                    widget.num = val.round();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.num.toString()),
                      )),
                    ),
                  ),
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: FlatButton(
                      child: Center(child: Text('Done', style: TextStyle(color: Colors.white),)),
                      onPressed: () {
                        print("pressed");
                        if (widget.num < widget.min || widget.num > widget.max) {
                          Flushbar(
                            message: "Value must between ${widget.min} and ${widget.max}.",
                            flushbarPosition: FlushbarPosition.BOTTOM,
                            duration: Duration(seconds: 3),
                            padding: EdgeInsets.all(20),
                            maxWidth: MediaQuery.of(context).size.width - 20,
                            borderRadius: 10,
                          )..show(context);
                        } else {
                          Navigator.pop(context, widget.num);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}