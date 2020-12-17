class Record{
  String _name;
  String _url;

  Record({String name, String url}){
    _name = name;
    _url = url;
  }

  String get name => _name;
  String get url => _url;

  setName(String name){
    this._name = name;
  }

  setUrl(String url){
    this._name = url;
  }
}