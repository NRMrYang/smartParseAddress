import 'AddressDatabase.dart';

class AddressParse {
  static List defaultData = [];
  static Map mCity = {};
  static Map mArea = {};

  static bool parseArea(List list, bool init){
    if((init == null || !init) && defaultData.length > 0){
      return true;
    }
    defaultData = list;
    defaultData.forEach((province) {
      if(province['city'] != null){
        province['city'].forEach((city) {
          if(city['name'] != '其他'){
            if(mCity[city['name']] == null){
              mCity[city['name']] = [];
            }
            mCity[city['name']].add({
              'p': province['name'],
              'c': city['name'],
              'a': city['area'] == null ? [] : city['area']
            });
          }
          if(city['area'] != null){
            city['area'].forEach((area) {
              if (area != '其他'){
                if(mArea[area] == null){
                  mArea[area] = [];
                }
                mArea[area].add({
                  'p': province['name'],
                  'c': city['name']
                });
              }
            });
          }
        });
      }
    });
    return true;
  }

  static Map parse(String address) {
    if(address == null){
      address = '';
    }
    Map parse = {
      'name': '',
      'mobile': '',
      'detail': '',
      'zip_code': '',
      'phone': ''
    };

    //自定义去除关键字，可自行添加
    const List search =  ['地址', '收货地址', '收货人', '收件人', '收货', '邮编', '电话', '：', ':', '；', ';', '，', ',', '。',' '];
    search.forEach((str) {
      address = address.replaceAll(str, ' ');
    });

    //多个空格replace为一个
    address = address.replaceAll(new RegExp('[ ]{2,}'), ' ');
    //整理电话格式
    RegExp phoneReg1 = new RegExp('([0-9]{3})-([0-9]{4})-([0-9]{4})');
    Iterable<Match> phones1 = phoneReg1.allMatches(address);
    List<String> phoneMatches1 = new List();
    for (Match m in phones1) {
      phoneMatches1.add(m.group(0));
    }
    if(phoneMatches1.length > 0){
      phoneMatches1.forEach((element) {
        address = address.replaceFirst(new RegExp(element), element.replaceAll('-', ''));
      });
    }
    RegExp phoneReg2 = new RegExp('(\\d{3})[ ](\\d{4})[ ](\\d{4})');
    Iterable<Match> phones2 = phoneReg2.allMatches(address);
    List<String> phoneMatches2 = new List();
    for (Match m in phones2) {
      phoneMatches2.add(m.group(0));
    }
    if(phoneMatches2.length > 0){
      phoneMatches2.forEach((element) {
        address = address.replaceFirst(new RegExp(element), element.replaceAll(' ', ''));
      });
    }

    RegExp mobileReg = new RegExp('(86-[1][0-9]{10})|(86[1][0-9]{10})|([1][0-9]{10})');
    Iterable<Match> mobiles = mobileReg.allMatches(address);
    List<String> mobileMatches = new List();
    for (Match m in mobiles) {
      mobileMatches.add(m.group(0));
    }
    if(mobiles.length > 0){
      parse['mobile'] = mobileMatches[0];
      address = address.replaceFirst(mobileMatches[0], '');
    }

    //电话/座机
    RegExp phoneReg = new RegExp('(([0-9]{3,4}-)[0-9]{7,8})|([0-9]{12})|([0-9]{11})|([0-9]{10})|([0-9]{9})|([0-9]{8})|([0-9]{7})');
    Iterable<Match> phones = phoneReg.allMatches(address);
    List<String> phoneMatches = new List();
    for (Match m in phones) {
      phoneMatches.add(m.group(0));
    }
    if(phones.length > 0){
      parse['phone'] = phoneMatches[0];
      address = address.replaceFirst(phoneMatches[0], '');
    }

    //邮编
    List zipCodeList = zipCodeFormat();
    for(int index = 0; index < zipCodeList.length; index++){
      if(address.indexOf(zipCodeList[index]) != -1){
        int num = address.indexOf(zipCodeList[index]);
        String code = address.substring(num, num + 6);
        parse['zip_code'] = code;
        address = address.replaceAll(code, '');
      }
    }

    address = address.replaceFirst(new RegExp('[ ]{2,}'), ' ');

    Map detail = detail_parse_forward(address.trim());
    String ignoreArea = detail['province'];
    if(detail['city'] == null || detail['city'] == ''){
      detail = detail_parse(address.trim());
      if((detail['area'] != null && detail['area'] != '') && (detail['city'] == null || detail['city'] == '')){
        detail = detail_parse(address.trim(), ignoreArea: true);
        print('smart_parse->ignoreArea（忽略区）');
      } else {
        //print('smart_parse');
      }
      //这个待完善
      List list = address.replaceFirst(detail['province'], '').replaceFirst(detail['city'], '').replaceFirst(detail['area'], '').split(' ');
      list = list.where((str) => (str != null && str != '')).toList();
      //详细住址划分关键字
      //注意：只需要填写关键字最后一位即可：比如单元填写元即可！
      List address_detail_list = ['室', '楼', '元', '号', '幢', '门', '户'];
      if(list.length > 1){
        list.forEach((str) {
          if((parse['name'] == null || parse['name'] == '') || (str != null && str != '') && str.length < parse['name'].length){
            parse['name'] = str.trim();
          }
        });
        if (parse['name'] != null && parse['name'] != '') {
          detail['addr'] = detail['addr'].replaceFirst(parse['name'], '').trim();
        }
      } else {//若名字写在详细地址后面，根据address_detail_list进行分割；
        List key = [];
        address_detail_list.forEach((el) {
          key.add(detail['addr'].indexOf(el));
        });
        key.sort((a,b) {
          return b - a;
        });
        int max = key[0];
        if (detail['name'] != null && detail['name'] != '') {
          parse['name'] = detail['name'];
        }
        if (max != -1) {
          String addrBuild = detail['addr'].substring(0, max + 1);
          String addrNum = detail['addr'].replaceFirst(addrBuild, '').replaceAll(new RegExp('[^0-9]+'), '');
          String userName = detail['addr'].replaceFirst(addrBuild + addrNum, '');
          detail['addr'] = addrBuild + addrNum;
          parse['name'] = userName;
        }
      }
    } else {
      if (detail['name'] != null && detail['name'] != '') {
        parse['name'] = detail['name'];
      } else {
        List list = detail['addr'].split(' ');
        list = list.where((str) => (str != null && str != '')).toList();
        if (list.length > 1) {
          parse['name'] = list[list.length - 1];
        }
        if (parse['name'] != null && parse['name'] != '') {
          detail['addr'] = detail['addr'].replaceFirst(parse['name'], '').trim();
        }
      }
    }
    parse['province'] = detail['province'] == '' ? ignoreArea : detail['province'];
    parse['city'] = detail['city'];
    parse['area'] = detail['area'];
    parse['addr'] = detail['addr'];
    parse['result'] = detail['result'];
    //添加省以及市（2019.6.21）输出字段后填入省市等等
    AddressDatabase.foramtProvince.forEach((el) {
      if(el['name'].indexOf(parse['province']) == 0){
        parse['province'] = el['name'];
      }
    });
    AddressDatabase.zipCode.forEach((provice) {
      if(parse['province'].indexOf(provice['name']) == 0){
        provice['child'].forEach((city) {
          if(city['name'].indexOf(parse['city']) == 0){
            parse['city'] = city['name'];
          }
        });
      }
    });
    return parse;
  }

  static List zipCodeFormat() {
    List list = new List();
    AddressDatabase.zipCode.forEach((el) {
      if (el['child'] != null) {
        el['child'].forEach((event) {
          if (event['child'] != null) {
            event['child'].forEach((element) {
              list.add(element['zipcode']);
            });
          }
        });
      }
    });
    return list;
  }

  static Map detail_parse_forward (String address){
    Map parse = {
      'province': '',
      'city': '',
      'area': '',
      'addr': '',
      'name': '',
    };

    List provinceKey = ['特别行政区', '古自治区', '维吾尔自治区', '壮族自治区', '回族自治区', '自治区', '省省直辖', '省', '市'];
    List cityKey = ['布依族苗族自治州', '苗族侗族自治州', '自治州', '州', '市', '县'];

    for(Map province in defaultData){
      int index = address.indexOf(province['name']);
      if(index > -1){
        if(index > 0) {
          //省份不是在第一位，在省份之前的字段识别为名称
          parse['name'] = address.substring(0, index).trim();
        }
        parse['province'] = province['name'];
        address = address.substring(index + province['name'].length);
        for(String key in provinceKey){
          if(address.indexOf(key) == 0){
            address = address.substring(key.length);
          }
        }
        for(Map city in province['city']){
          index = address.indexOf(city['name']);
          if(index > -1 && index < 3){
            parse['city'] = city['name'];
            address = address.substring(index + parse['city'].length);
            for(String key in cityKey){
              if(address.indexOf(key) == 0){
                address = address.substring(key.length);
              }
            }
            if (city['area'] != null){
              for(String area in city['area']){
                index = address.indexOf(area);
                if(index > -1 && index < 3){
                  parse['area'] = area;
                  address = address.substring(index + parse['area'].length);
                  break;
                }
              }
            }
            break;
          }
        }
        parse['addr'] = address.trim();
        break;
      }
    }
    return parse;
  }
  
  static Map detail_parse(String address, {bool ignoreArea: false}){
    Map parse = {
      'province': '',
      'city': '',
      'area': '',
      'name': '',
      '_area': '',
      'addr': '',
    };
    int areaIndex = -1, cityIndex = -1;
    
    address = address.replaceFirst('  ', ' ');
    
    if((!ignoreArea && address.indexOf('县') > -1) || (!ignoreArea && address.indexOf('区') > -1) || (!ignoreArea && address.indexOf('旗') > -1)){
      if (address.indexOf('旗') > -1) {
        areaIndex = address.indexOf('旗');
        parse['area'] = address.substring(areaIndex - 1, (areaIndex - 1) + 2);
      }
      if (address.indexOf('区') > -1) {
        areaIndex = address.indexOf('区');
        if (address.lastIndexOf('市', areaIndex) > -1){
          cityIndex = address.lastIndexOf('市', areaIndex);
          parse['area'] = address.substring(cityIndex + 1, (cityIndex + 1) + areaIndex - cityIndex);
        }
      }
      if (address.indexOf('县') > -1) {
        areaIndex = address.indexOf('县');
        if (address.lastIndexOf('市', areaIndex) > -1){
          cityIndex = address.lastIndexOf('市', areaIndex);
          parse['area'] = address.substring(cityIndex + 1, (cityIndex + 1) + areaIndex - cityIndex);
        } else {
          parse['area'] = address.substring(areaIndex - 2, (areaIndex - 2) + 3);
        }
      }
      parse['addr'] = address.substring(areaIndex + 1);
    } else {
      if (address.indexOf('市') > -1) {
        areaIndex = address.indexOf('市');
        print(address.split(' '));
        if (address.split(' ')[0].indexOf('市') > -1) {
          int areindex = address.split(' ')[0].indexOf('市');
          parse['area'] = address.split(' ')[0].substring(0, areindex + 1);
          parse['addr'] = address.split(' ')[0].substring(areindex + 1);
          if(address.split(' ').length > 1){
            parse['name'] = address.split(' ')[1];
          }else{
            parse['name'] = '';
          }
        } else {
          if(address.split(' ').length > 1){
            int areindex = address.split(' ')[1].indexOf('市');
            parse['area'] = address.split(' ')[1].substring(0, areindex + 1);
            parse['addr'] = address.split(' ')[1].substring(areindex + 1);
          }else{
            parse['area'] = '';
            parse['addr'] = '';
          }
          parse['name']  = address.split(' ')[0];
        }
      } else {
        parse['addr'] = address;
      }
    }

    if (address.indexOf('市') > -1 || address.indexOf('盟') > -1 || address.indexOf('州') > -1) {
      if (address.indexOf('市') > -1) {
        parse['_area'] = address.substring(address.indexOf('市') - 2, address.indexOf('州'));
      }
      if (address.indexOf('盟') > -1 && !mCity[parse['_area']]) {
        parse['_area'] = address.substring(address.indexOf('盟') - 2, address.indexOf('州'));
      }
      if (address.indexOf('州') > -1 && !mCity[parse['_area']]) {
        parse['_area'] = address.substring(address.indexOf('州') - 2, address.indexOf('州'));
      }
    }

    parse['area'] = parse['area'].trim();
    if (parse['area'] != null && parse['area'] != '' && mArea[parse['area']] != null) {
      if (mArea[parse['area']].length == 1) {
        parse['province'] = mArea[parse['area']][0]['p'];
        parse['city'] = mArea[parse['area']][0]['c'];
      } else {
        parse['_area'] = parse['_area'].trim();
        String addr = address.substring(0, areaIndex);
        Map d = new Map();
        for(Map item in mArea[parse['area']]){
          if(item['p'].indexOf(addr) > -1 || item['c'] == parse['_area']){
            d = item;
            break;
          }
        }
        if (d.isNotEmpty) {
          parse['province'] = d['p'];
          parse['city'] = d['c'];
        } else {
          parse['result'] = mArea[parse['area']];
        }
      }
    } else {
      if (parse['_area'] != null && parse['_area'] != '' ) {
        List city = mCity[parse['_area']];
        if (city.length > 0) {
          parse['province'] = city[0].p;
          parse['city'] = city[0].c;
          parse['addr'] = address.substring(address.indexOf(parse['city']) + parse['city'].length + 1);
          parse['area'] = '';
          for (String area in city[0]['a']) {
            if (parse['addr'].indexOf(area) == 0) {
              parse['area'] = area;
              parse['addr'] = parse['addr'].replaceFirst(area, '');
              break;
            }
          }
        }
      } else {
        parse['area'] = '';
      }
    }
    parse['addr'] = parse['addr'].trim();
    return parse;
  }
}

