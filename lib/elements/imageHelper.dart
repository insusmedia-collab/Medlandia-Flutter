import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Imagehelper {

  final ImagePicker _imagePicker;// = ImagePicker();
  final ImageCropper _imageCropper;// = ImageCropper();

  Imagehelper(ImagePicker? imagePicker, ImageCropper? imageCropper) 
  : _imagePicker = imagePicker ?? ImagePicker(),
    _imageCropper = imageCropper ?? ImageCropper();

  Future<XFile?>  pickImage({
    ImageSource imageSource = ImageSource.gallery,
    int imageQuality = 100
  }) async {
    final file =  await _imagePicker.pickImage(source: imageSource, imageQuality: imageQuality);
    return file;
  }

  Future<CroppedFile?> crop({
    required XFile file, 
    CropStyle cropStyle = CropStyle.circle
  }) async => await _imageCropper.cropImage(
                        sourcePath: file.path
                        /*compressQuality: 100,
                        uiSettings: [
                          IOSUiSettings(),
                          AndroidUiSettings()
                        ]*/);

}