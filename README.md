# tsinghua

移动应用软件开发——校园论坛App



## 框架

 - 前端<br>
 dart语言flutter

 - 后端<br>
 springboot3 + redis + mysql + rabbitmq + docker


## Figma设计草稿
https://www.figma.com/file/4rHcBVTRFyxY4Xa7FRaoiA/%E5%AE%89%E5%8D%93%E8%AF%BEUI?type=design&node-id=1-69&mode=design&t=XrYfaAK49ejMNrAN-0



## 配置
内置动画弹窗组件<br>
https://juejin.cn/post/7076083351668555813




## 问题与解决

1. 键盘弹出遮挡输入框问题 <br>
   https://stackoverflow.com/questions/51335483/flutter-keyboard-makes-textfield-hide

   ```dart
   return Scaffold(
     appBar: AppBar(
       title: Text("TitleBar"),
     ),
     resizeToAvoidBottomInset: true,
     body: SingleChildScrollView(
       child: ... some widgets here...
       ,
     ),
   );
   ```

2. 获取当前路由路径 <br>
    https://stackoverflow.com/questions/46483949/how-to-get-current-route-path-in-flutter
    ``` dart
    ModalRoute.of(context).settings.name
    ```

    上面的代码可能会出现值为null，所以需设置settings参数
    https://github.com/flutter/flutter/issues/50192#issuecomment-590307455
    ``` dart
    Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings, // 这行
      builder: (BuildContext context) {
          //some custom code
          return _data[settings.name](context);
        }
      );
    }
    ```

3. 底下弹出框
    https://pub.dev/packages/modal_bottom_sheet/install

https://stackoverflow.com/questions/72359239/how-to-return-data-from-custom-function-which-uses-bottom-sheet-in-flutter
   
   https://stackoverflow.com/questions/52414629/how-to-update-state-of-a-modalbottomsheet-in-flutter