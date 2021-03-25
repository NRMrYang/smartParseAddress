# smartParseAddress
Dart/Flutter地址智能识别源码，类似顺丰填写地址的智能识别，识别率95%+

站在巨人肩膀上，前排感谢：GitHub@wzc570738205
实际就是将[地址智能识别](https://github.com/wzc570738205/smart_parse)转化为dart语言

以下为作者原README.md


## [原项目](https://github.com/wzc570738205/smart_parse)已不再维护，请移步最新地址：[地址智能识别](https://github.com/wzc570738205/smartParsePro)
## 点击此处预览：[预览地址](https://wzc570738205.github.io/smart_parse/)
## 欢迎加群：[749539640](https://jq.qq.com/?_wv=1027&k=55bQp1O)

## 地址数据来源(如有更新请更新此js)
```
area-list.js
```
## 支持以下数据格式
### 最新支持数据格式：
#### 北京市朝阳区富康路姚家园3楼马云150-0000-0000
#### 北京市朝阳区富康路姚家园3号楼5单元3305马云15000000000
#### 北京市朝阳区富康路姚家园3号楼5单元3305马云15000000000邮编038300
1. 马云,1351111111,北京市朝阳区姚家园3楼
2. 马云1351111111北京市朝阳区姚家园3楼
3. 北京市朝阳区姚家园3楼1351111111马云
4. 北京市朝阳区姚家园3楼150-0000-0000马云
## 不支持的数据格式
不支持富康路姚家园3号楼5单元3301后直接加电话<br>
ex.北京市朝阳区富康路姚家园3号楼5单元330115000000000邮编038300

## 地址切分规则
1. `省市区(县)`+`详细地址（不包括楼、单元、室等等）`+`电话`+`邮编`+`姓名`
2. `省市区(县)`+`详细地址+楼+单元+室等`+`姓名`+`电话`+`邮编`
## 生成数据格式
```
{
addr: "姚家园3楼"
area: "朝阳区"
city: "北京"
detail: ""
mobile: "15000000000"
name: "马云"
phone: ""
province: "北京"
result: undefined
zip_code: ""
}
```
##### 参考链接（php）（https://github.com/pupuk/address-smart-parse ）
##### 参考地址： [简书](https://www.jianshu.com/p/694b062c52e7)
##### 地址数据来源：[中华人民共和国行政区划](https://github.com/modood/Administrative-divisions-of-China)


