import router from '@ohos.router';
import systemDateTime from '@ohos.systemDateTime';


@Entry
@Component
struct Page2 {
  //@State message: string = 'Hello World';

  build() {
    Column() {

      Row(){


      }.id('上行')
      .width('100%')
      .height('20%')
      .backgroundColor(Color.Brown)
      .justifyContent(FlexAlign.SpaceBetween)


      Row(){

        Column(){
          Text("今日检查")
            .fontSize(40)
            .fontWeight(FontWeight.Bold)

        }

      }.id('中行')
      .width('100%')
      .height('60%')
      .backgroundColor(Color.Blue)
      .justifyContent(FlexAlign.SpaceEvenly)


      Row() {



      }.id('下行')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.Green)
      .height('20%')
      .width('20%')

    }.id('总布局')
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.Gray)

  }
}