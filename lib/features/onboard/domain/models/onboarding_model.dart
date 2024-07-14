class OnBoardingModel{
  final String _imageUrl;
  final String _frameImageUrl;
  final String _title;
  final String _description;

  get imageUrl => _imageUrl;
  get frameImageUrl => _frameImageUrl;
  get title => _title;
  get description => _description;

  OnBoardingModel(this._imageUrl, this._frameImageUrl, this._title, this._description);
}