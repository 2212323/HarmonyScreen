import router from '@ohos.router';
import http from '@ohos.net.http';
import systemDateTime from '@ohos.systemDateTime';
let httpRequest = http.createHttp();

interface Bed {
  BedName: string;
  PID?: number;
}
interface MedicalOrder {
  MOID: number;
  PID?: number;
  MID?: number;
  NuringLevel?: string;
  MedicationDetails?: string;
  StartTime?: string;
  EndTime?: string;
  type?: string;
  status?: string;
}
interface Doctor {
  MID: number;
  DID?: number;
  Mname?: string;
}
@Entry
@Component
struct Page2 {
  @State MOID: number=0;
  @State PID?: number=1;
  @State MID?: number=0;
  @State NuringLevel?: string="";
  @State MedicationDetails?: string="";
  @State StartTime?: string="";
  @State EndTime?: string="";
  @State type?: string="";
  @State status?: string="";
  @State doctorName:String="";
  @State action:boolean=false;
  @State bednum:string="Bed2";
  //@State message: string = 'Hello World';

  IPstr():string//在这里修改IP地址
  {
    //return `http://127.0.0.1/`;
    return `http://192.168.43.215/`;
    //return `http://10.128.118.164/`;
  }
  InsertStr(tableName:string,data:string):string//在tableName里插入data,data要求格式为“属性：内容”
  {
    return this.IPstr()+`intsert?tableName=`+tableName+`&data=`+data;
  }
  DeleteStr(tableName:string,condition:string):string//在tableName里删除条件为condition的数据,condition要求格式为正常的SQL格式，把=换成：
  {
    return this.IPstr()+`delete?tableName=`+tableName+`&condition=`+condition;
  }
  UpdateStr(tableName:string,data:string,condition:string):string//在tableName里把条件为condition的数据更新为data,要求同上
  {
    return this.IPstr()+`update?tableName=`+tableName+`&data=`+data+`&condition=`+condition;
  }
  SelectStr(tableName:string,condition:string):string//在tableName里查找条件为condition的数据，要求同上
  {
    return this.IPstr()+`query?tableName=`+tableName+`&condition=`+condition;
  }

  getData(url: string): Promise<string> {//调用方式：await this.getData(url)返回字符串，url来自上面的函数返回
    return new Promise((resolve, reject) => {
      let backdata: string = "are???";
      httpRequest.request(url, (err: Error, data: http.HttpResponse) => {
        if (!err) {
          console.info('Result: ' + data.result);
          console.info(typeof(data.result));
          backdata = data.result.toString(); // 确保数据为字符串类型
          resolve(backdata); // 成功时解析 Promise 并返回数据
        } else {
          console.info('error: ' + JSON.stringify(err));
          reject(err); // 失败时拒绝 Promise 并返回错误
        }
      });
    });
  }
  async fetchData() {
    console.log("dadaa"+this.SelectStr("bed", "BedName:"+this.bednum));
    const BEDData: Bed[] = JSON.parse(await this.getData(this.SelectStr("bed", "BedName:\""+this.bednum+"\"")));
    console.log("llll"+BEDData.toString());
    this.PID = BEDData[0]?.PID?.valueOf() || 0;
    console.log("PID!!"+this.PID.toString());

    const patientData: MedicalOrder[] = JSON.parse(await this.getData(this.SelectStr("medicalorder", "PID:"+this.PID)));
    this.MOID=patientData[0]?.MOID?.valueOf()||0;
    this.PID=patientData[0]?.PID?.valueOf()||0;
    this.MID=patientData[0]?.MID?.valueOf()||0;
    this.NuringLevel=patientData[0]?.NuringLevel?.toString()||"";
    this.MedicationDetails=patientData[0]?.MedicationDetails?.toString()||"";
    this.StartTime=patientData[0]?.StartTime?.toString()||"";
    this.EndTime=patientData[0]?.EndTime?.toString()||"";
    this.type=patientData[0]?.type?.toString()||"";
    this.status=patientData[0]?.status?.toString()||"";
    console.log(`MOID: ${this.MOID}`);
    console.log(`PID: ${this.PID}`);
    console.log(`MID: ${this.MID}`);
    console.log(`NuringLevel: ${this.NuringLevel}`);
    console.log(`MedicationDetails: ${this.MedicationDetails}`);
    console.log(`StartTime: ${this.StartTime}`);
    console.log(`EndTime: ${this.EndTime}`);
    console.log(`type: ${this.type}`);
    console.log(`status: ${this.status}`);
    const doctorData: Doctor[] = JSON.parse(await this.getData(this.SelectStr("doctor", "MID:"+this.MID)));
    this.doctorName=doctorData[0]?.Mname?.toString()||"";
    console.log(`doctorName: ${this.doctorName}`);


  }
  aboutToAppear(){
    this.fetchData();
    // console.log(`MOID: ${this.MOID}`);
    // console.log(`PID: ${this.PID}`);
    // console.log(`MID: ${this.MID}`);
    // console.log(`NuringLevel: ${this.NuringLevel}`);
    // console.log(`MedicationDetails: ${this.MedicationDetails}`);
    // console.log(`StartTime: ${this.StartTime}`);
    // console.log(`EndTime: ${this.EndTime}`);
    // console.log(`type: ${this.type}`);
    // console.log(`status: ${this.status}`);

  }


  build() {
    Column() {

      Row(){



        Text("医生姓名:"+this.doctorName.toString())
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .border({ width: 3, color: Color.Black, radius: 10, style: BorderStyle.Solid })
          .borderRadius(5)

      }.id('上行')
      .width('100%')
      .height('10%')
      //.justifyContent(FlexAlign.SpaceBetween)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding(10)


      Row(){


        Column(){



          Row(){

            Text("今日医嘱")
              .fontSize(40)
              .fontWeight(FontWeight.Bold)

          }.justifyContent(FlexAlign.Start)
          .padding(7)




          Column(){

            Scroll(){
              Text(this.MedicationDetails)
              //Text("naoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkdnaoncanoiancoiasdncnanckdllllllllllllllllllllllllllljaslkcnaslkcnaBChabclkanclkaclianclanclanclanlakhnclkxznlidanclkd")
                .fontSize(30)
                .fontWeight(FontWeight.Medium)

            }.align(Alignment.Top)
            .border({ width: 5, color: Color.Black, radius: 15, style: BorderStyle.Solid })
            .height('100%')
            .width('100%')
            .scrollBar(BarState.On)
            .padding(3)


          }.width('100%')
          .height('90%')
          .justifyContent(FlexAlign.Start)




        }.id('中行中列')
        .width('80%')
        .height('100%')
        .padding(5)
        .justifyContent(FlexAlign.Start)
        //.border({ width: 5, color: Color.Black, radius: 15, style: BorderStyle.Solid })




      }.id('中行')
      .width('100%')
      .height('80%')
      .justifyContent(FlexAlign.SpaceEvenly)
      //.backgroundColor(Color.Red)


      Row() {

        Column() {


          Button('返回').onClick(() => { //页面跳转
            router.pushUrl({ url: 'pages/Index' })
          })

        }.height('100%')
        .width('20%')
        //.backgroundColor(Color.Pink)
        .justifyContent(FlexAlign.End)//正常轴
        .alignItems(HorizontalAlign.Start)//交叉轴
        .padding(10)



        Row(){

          Button('执行',{ type: ButtonType.Normal, stateEffect: true })
            .borderRadius(8)
            .backgroundColor(0x5CB85C)//92 184 92  //绿色
            .width(110)
            .height(70)
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .onClick(() => { //页面跳转

              this.action=true;

              console.log(this.UpdateStr("medicalorder","status:\"已执行\"","MOID:"+this.MOID));
              this.getData(this.UpdateStr("medicalorder","status:\"已执行\"","MOID:"+this.MOID));

              //router.pushUrl({ url: 'pages/Index' })
            })

          Button('不执行',{ type: ButtonType.Normal, stateEffect: true })
            .borderRadius(8)
            .backgroundColor(0xD9534F)//红色 217 83 79#
            .width(110)
            .height(70)
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .onClick(() => { //页面跳转

              this.action=false;
              console.log(this.UpdateStr("medicalorder","status:\"已执行\"","MOID:"+this.MOID));
              this.getData(this.UpdateStr("medicalorder","status:\"作废\"","MOID:"+this.MOID));
              //router.pushUrl({ url: 'pages/Index' })
            })



        }.width('60%')
        .height('100%')
        .padding(5)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Top)

        Column(){

          // Button('BLE').onClick(() => { //页面跳转
          //   router.pushUrl({ url: 'pages/BLE' })
          // })

        }.width('20%')
        .height('100%')

      }.id('下行')
      .justifyContent(FlexAlign.SpaceBetween)
      //.backgroundColor(Color.Green)
      .height('10%')
      .width('100%')

    }.id('总布局')
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    //.backgroundColor(Color.Gray)
    .backgroundColor("#f7f6f0d3")
  }
}
