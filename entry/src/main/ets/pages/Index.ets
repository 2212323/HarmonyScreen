import bundle from '@ohos.bundle';
import featureAbility from '@ohos.ability.featureAbility';
import UIAbility from '@ohos.app.ability.UIAbility';

import Window from '@ohos.window'
import common from '@ohos.app.ability.common';

import router from '@ohos.router';

import { EditableLeftIconType } from '@ohos.arkui.advanced.EditableTitleBar'
import http from '@ohos.net.http';

//BLE
import ble from "@ohos.bluetooth.ble"
import { BusinessError } from '@ohos.base'
import window from '@ohos.window';
interface Bed {
  BedName: string;
  PID?: number;
}
// Department 表的接口
interface Department {
  DID: number;
  Dname?: string;
}

// MedicalOrder 表的接口
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

// MedicalStaff 表的接口
interface MedicalStaff {
  MID: number;
  DID?: number;
  Mname?: string;

}

// Doctor 表的接口
interface Doctor {
  MID: number;
  DID?: number;
  Mname?: string;
}

// Nurse 表的接口
interface Nurse {
  MID: number;
  DID?: number;
  Mname?: string;
  MAC?:string;
}

// Nursing 表的接口
interface Nursing {
  MID: number;
  PID: number;
}

// Patient 表的接口
interface Patient {
  PID: number;
  DID?: number;
  Pname?: string;
  age?: number;
  gender?: string;
  admission_date?: string; // 使用 string 类型来表示日期
  illness?: string;
  allergen?: string;
}

// Treat 表的接口
interface Treat {
  MID: number;
  PID: number;
}

interface  BleDevices{
  BedName:string;
  RSSI:number;
}


let httpRequest = http.createHttp();

const minRssi = -200//BLE信号强度

@Entry
@Component

struct Index {


  @State roomnum: number = 0
  @State roomtype: string=''
  @State bednum: string='Bed2'

  @State PDA:string=''
  @State name:string=''
  @State gender:string=''
  @State age:Number =0
  @State warning:string=''
  @State nurseName:string =''
  @State nurseID:number = 0
  @State MAC:string = ''
  @State doctor:string =''
  @State PID:Number=1
  @State responseData: string = "Loading...";

  @State Active:string="";


  @State message: string = 'Hello BLE'
  @State receivedText: string = 'No Data Received'
  @State availableDevices: Array<ble.ScanResult> = [] //能查到的设备
  @State Rssi:number=-200;
  @State isFullScreen:boolean = false


  aboutToAppear() {

    // let windowClass: Window.Window;
    // //获取上下文
    // //var context = getContext(this) as any
    // // 获取上下文，使用common模块
    // let context = getContext(this) as common.UIAbilityContext;
    // let promise = Window.getLastWindow(context);
    // promise.then((data) => {
    //   windowClass = data;
    //   //切换成横屏
    //   let orientation = Window.Orientation.LANDSCAPE;
    //   windowClass.setPreferredOrientation(orientation, (err) => {
    //   });
    //   //this.portrait = !this.portrait
    //   //console.info('Succeeded in obtaining the top window. Data: ' + JSON.stringify(data));
    //
    // })


    this.fetchData();

    //ble.stopBLEScan()//抱着试一试的心态
    this.openBle();
    // this.stopTimer(); //
    // this.startTimer(1); // 每1秒调用一次异步函数
    // //this.openBle();

  }
  horVerSwitch(){
    let context = getContext(this) as common.UIAbilityContext;
    // 使用getLastWindow获取当前窗口
    window.getLastWindow(context).then((lastWindow)=>{
      // 使用setPreferredOrientation实现横竖屏切换
      lastWindow.setPreferredOrientation(this.isFullScreen ? window.Orientation.PORTRAIT : window.Orientation.LANDSCAPE)
      this.isFullScreen = !this.isFullScreen
    })
  }

  private intervalId: number | null = null;
  // 初始化定时器
  startTimer(intervalInSeconds: number) {
    this.intervalId = setInterval(async () => {
      try {
        await this.callAsyncFunction();
      } catch (error) {
        console.error("Error calling async function:", error);
      }
    }, intervalInSeconds * 1000);
  }

  // 停止定时器
  stopTimer() {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  // 异步函数
  async callAsyncFunction() {
    //await this.fetchData();
    //this.getData(this.BleStr(this.bednum , 12));// 但是业务逻辑保证只有一个rssi
    await this.openBle();

    console.log('Async function called');
  }
  //需要后端DateBaseHelper.java文件存在并设置好数据库名，账户密码
  IPstr():string//在这里修改IP地址
  {
    //return `http://192.168.43.215/`;
    return `http://192.168.1.5/`;
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
  BleStr(BedName:string,RSSI:number):string//在tableName里把条件为condition的数据更新为data,要求同上
  {
    return this.IPstr()+`uploadRSSI?BedName=`+BedName+`&RSSI=`+RSSI;
  }


  AskStr(BedName:string)
  {
    return this.IPstr()+`askActive?BedName=`+BedName;
  }
  async ToNext()
  {

    console.log(router.getState().name);

    this.Active=await this.getData(this.AskStr(this.bednum));
    console.log("ACTIVE",this.Active)
    //console.log("router.getState().name",router.getState().name)
    console.log("this.Active==true"+this.Active.match("true"))
    console.log("router.getState().name"+(router.getState().name=="Index"))
    if((this.Active.match("true")) && (router.getState().name=="Index"))
    {
      console.log("111router.getState().name",router.getState().name)
      router.pushUrl({ url: 'pages/Page2' });

    }
    else if(this.Active.match("false") && router.getState().name=="Page2")
    {
      //router.pushUrl({ url: 'pages/Index' });
      router.back();
    }
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

    //console.log(await this.getData(url));
    try {
      console.log("dadaa"+this.SelectStr("bed", "BedName:"+this.bednum));
      const BEDData: Bed[] = JSON.parse(await this.getData(this.SelectStr("bed", "BedName:\""+this.bednum+"\"")));
      console.log("llll"+BEDData.toString());
      this.PID = BEDData[0]?.PID?.valueOf() || 0;
      console.log("PID!!"+this.PID.toString());
      const patientData: Patient[] = JSON.parse(await this.getData(this.SelectStr("patient", "PID:"+this.PID)));
      if (patientData && patientData.length > 0) {
        this.name = patientData[0]?.Pname?.toString() || '';
        this.age = patientData[0]?.age?.valueOf() || 0;
        this.gender = patientData[0]?.gender?.toString() || '';
        this.roomnum = patientData[0]?.DID?.valueOf() || 0;
        this.warning = patientData[0]?.illness?.toString() || '';
      }

      const temNurData: Nursing[] = JSON.parse(await this.getData(this.SelectStr("nursing", "PID:"+this.PID)));
      if (temNurData && temNurData.length > 0) {
        const nurseData: Nurse[] = JSON.parse(await this.getData(this.SelectStr("nurse", "MID:" + temNurData[0].MID)));
        if (nurseData && nurseData.length > 0) {
          this.nurseName = nurseData[0]?.Mname?.toString() || '';
          this.nurseID = nurseData[0]?.MID?.valueOf() || 0;
          this.MAC = nurseData[0]?.MAC?.toString() || '';
        }
      }

      const temDocData: Nursing[] = JSON.parse(await this.getData(this.SelectStr("treat", "PID:"+this.PID)));
      if (temDocData && temDocData.length > 0) {
        const doctorData: Doctor[] = JSON.parse(await this.getData(this.SelectStr("doctor", "MID:" + temDocData[0].MID)));
        if (doctorData && doctorData.length > 0) {
          this.doctor = doctorData[0]?.Mname?.toString() || '';
        }
      }

      const depData: Department[] = JSON.parse(await this.getData(this.SelectStr("department", "DID:" + patientData[0]?.DID)));
      if (depData && depData.length > 0) {
        this.roomtype = depData[0]?.Dname?.toString() || '';
      }

      //this.bednum = "Bed2";


    } catch (error) {
      console.error('Error fetching data:', error);
    }


  }


  //BLE相关函数
  addData(data: ble.ScanResult): void {
    let bFind = false
    this.availableDevices.forEach(element => {
      if (!bFind && element.deviceId == data.deviceId) {
        //console.info('BLE scan update ' + data.deviceId + ' rssi:' + element.rssi + ' ==> ' + data.rssi)
        element.rssi = data.rssi
        //this.Rssi=data.rssi;
        bFind = true
      }
    })
    if (!bFind) {
      //console.info('BLE scan add ' + data.deviceId + ' count:' + this.availableDevices.length)
      this.availableDevices.push(data)//把能查到的设备存入availableDevices
      this.message = 'BLE count:' + this.availableDevices.length

      // 处理接收到的数据
      const allData = (data.data)
      if (allData) {
        this.receivedText = this.arrayBufferToString(allData)
      }
    }
  }
  
  arrayBufferToString(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer)
    let result = ''
    for (let i = 0; i < bytes.length; i++) {
      result += String.fromCharCode(bytes[i])
    }
    return result
  }

  findMacInString(data: ArrayBuffer) : string {
    const MAC_raw = new Uint8Array(data)
    const temp:string='med'
    let MAC = ''
    for (let i = 0; i < MAC_raw.length; i++) {
      if((i+6)<MAC_raw.length && String.fromCharCode(MAC_raw[i])=='m' && String.fromCharCode(MAC_raw[i+1])=='e' && String.fromCharCode(MAC_raw[i+2])=='d')
      {
        MAC = String.fromCharCode(MAC_raw[i+3])+String.fromCharCode(MAC_raw[i+4])+String.fromCharCode(MAC_raw[i+5])+String.fromCharCode(MAC_raw[i+6])
      }
      //好优雅的代码啊！！！
    }
    return MAC;
  }

  openBle(): void {
    console.log("MACCCCCCCCCCCCCC"+this.MAC)
    try {

      ble.on("BLEDeviceFind", (data: Array<ble.ScanResult>) => {
        let i = 0

        data.forEach(element => {
          //console.info('BLE scan device[' + i + '] deviceId = ' + element["deviceId"] +
          //' name = ' + element["deviceName"] +
          //' rssi = ' + element["rssi"] +
          //' data[' + element["data"].byteLength + '] = ' +
          //this.arrayBufferToString(element["data"]))


          if (element.rssi > minRssi && element.deviceName != '') { //获取所有设备的rssi
            this.addData(element)
            //this.findMacInString(element.data) == this.MAC
            console.log("MACCCCCCCCCCCCCC" + this.MAC)
            if(this.findMacInString(element.data) == this.MAC) //如果data中的MAC和此设备授权的MAC匹配
            {
              console.log("keyjudge"+(this.findMacInString(element.data) == this.MAC))
              console.log("MACCCCCCCCCCCCCC" + this.MAC)
              console.log("MABBBBBBBBBBB" + this.findMacInString(element.data))
              this.getData(this.BleStr(this.bednum ,element.rssi ));// 但是业务逻辑保证只有一个rssi   element.rssi
            }
            // else{
            //
            //   console.log("MABBBBBBBBBBB" + this.findMacInString(element.data))
            //   this.getData(this.BleStr(this.bednum ,-200 ));
            //
            // }
            console.log("bednum!!!!!!",this.bednum)


          }
          this.fetchData()
          this.ToNext()

          //i++
        })


      })

      ble.startBLEScan(
        null,
        {
          interval: 500,
          dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
          matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE,
        }
      )
    } catch (err) {
      // console.error("ble errCode:" + (err as BusinessError).code + ",errMessage:" + (err as BusinessError).message)
    }
  }



  getServices(code: BusinessError, gattServices: Array<ble.GattService>):void {
    if (code.code == 0) {
      let services: Array<ble.GattService> = gattServices;
      //console.log('bluetooth code is ' + code.code);
      //console.log('bluetooth services size is ', services.length);

      for (let i = 0; i < services.length; i++) {
        //console.log('bluetooth serviceUuid is ' + services[i].serviceUuid);
      }
    }
  }//'48:3F:E9:73:09:52'


aboutToDisappear(): void {
      console.log("哈哈 我等不及要去死辣")
}



  build() {

    // let orientation = bundle.DisplayOrientation.LANDSCAPE;
    // context.setDisplayOrientation(orientation, (err) => {
    //   this.portrait = !this.portrait
    //   console.info("setDisplayOrientation err: " + JSON.stringify(err));
    // });


    Column() {
      //上行
      Row() {

        Column() {
          Column(){ Text('病房类型:' + this.roomtype)
  .fontSize(30)
  .fontWeight(FontWeight.Regular)
  .fontColor(Color.White)
  //.fontStyle(FontStyle.Italic)

  Text('病房号:' + this.roomnum)
    .fontSize(30)
    .fontWeight(FontWeight.Regular)
    .fontColor(Color.White)
          }.backgroundColor(Color.Grey)


          // Button('fk u')
          //   .onClick(() => {
          //     this.horVerSwitch()
          //   }).border({ width: 2, color: Color.Black, radius: 100, style: BorderStyle.Solid })
          //   .borderRadius({ topLeft: 0 })


          //.offset({ x: '-29%', y: '0%' })//x表示右边在x轴上的位置
        }
        .width('70%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        Column() {

          Column(){
            Text('PDA识别\n检测中..')
              .fontSize(30)
              .fontWeight(FontWeight.Regular)
          }.border({ width: 2, color: Color.Black, radius: 0, style: BorderStyle.Solid })

          // Text(this.PDA)
          //   .fontSize(35)
          //   .fontWeight(FontWeight.Regular)
        }

        .justifyContent(FlexAlign.Start)
        .width('30%')
        .height('100%')
        .alignItems(HorizontalAlign.End)
        //.offset({ x: '40%', y: '0%' })//x表示左边在x轴上的位置
        //.offset({ x: '60', y: '0%' })
      }
      .id('上行')

      .width('100%')
      .height('15%')
      //.backgroundColor(Color.Grey)
      .justifyContent(FlexAlign.Start)

      //.justifyContent(FlexAlign.SpaceBetween)
      //.backgroundColor(Color.Blue)

      //中行
      Row() {

        // //中行左列
        // Row() {
        //   Text(this.warning)
        //     .fontSize(30)
        //     .fontWeight(FontWeight.Regular)
        // }.width('20%')
        // .height('30%')
        // .border({ width: 2, color: Color.Black, radius: 10, style: BorderStyle.Solid })


        //Row() {
        //中行中列
        Column() {

          Column() {

            Text(this.name)
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .height('50%')
            Text(this.gender + ' ' + this.age)
              .fontSize(35)
              .fontWeight(FontWeight.Regular)
              .height('50%')


          }.width('50%')
          .height('30%')
          .border({ width: 2, color: Color.Black, radius: 10, style: BorderStyle.Solid })
          .justifyContent(FlexAlign.Center)

          Column() {
            Row() {
              Image($r('app.media.tanhao'))
                .width('15%')
              Text('注意事项：')
                .fontSize(35)
                .fontWeight(FontWeight.Regular)


              //.fontColor(Color.Red)
            } //.width('35%')
            // .height('30%')
            // .border({ width: 2, color: Color.Black, radius: 10, style: BorderStyle.Solid })

            Shape() {  Rect().width('60%').height(5).fill("#BD3124")}//


            Row() {
              Text(this.warning)
                .fontSize(30)
                .fontWeight(FontWeight.Regular)

            }.width('80%')
            .height('60%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Top)
            .padding(10)

          }.width('65%')
          .height('60%')
          .justifyContent(FlexAlign.Start)
          .border({ width: 2, color: Color.Black, radius: 10, style: BorderStyle.Solid })



        }.id('中行中列')
        .width('100%')
        .height('100%')
        //.backgroundColor(Color.Yellow)
        .justifyContent(FlexAlign.SpaceBetween)


        // .markAnchor({x: '-50%', y: '-50%'})//锚点默认为右上角！！！//以右上角为原点，建立正常坐标系
        // .offset({ x: '0%', y: '-10%' })//x表示左边在x轴上的位置//以左上角为原点，向右为x轴正方向，向下为y轴正方向

        //.markAnchor({x: '-50%', y: '-50%'})
        //.offset({ x: '1%', y: '0%' })//x表示左边在x轴上的位置


        // //中行右列
        // Column(){
        //   Text(this.Rssi.toString())
        //     .fontSize(30)
        //     .fontWeight(FontWeight.Regular)
        //
        //
        //
        // }.width('20%')
        // .height('30%')
        // .border({ width: 2, color: Color.Black, radius: 10, style: BorderStyle.Solid })

      }.id("中行")
      //.backgroundColor(Color.Green)
      .width('100%')
      .height('60%')
      .justifyContent(FlexAlign.SpaceEvenly)

      //下行
      Row(){
        //下行左列
        Row() {

          Column() {
            Row() {
              Text('主治医生👨🏻‍⚕️:')
                .fontSize(30)
                .fontWeight(FontWeight.Regular)
              //Image($r('app.media.doctor'))
                //.width('12%')
              Text(this.doctor)
                .fontSize(30)
                .fontWeight(FontWeight.Regular)
            }


            Row() {
              Text('负责护士👩🏻‍⚕️:')
                .fontSize(30)
                .fontWeight(FontWeight.Regular)
              //Image($r('app.media.nurse'))
                //.width('12%')
              Text(this.nurseName)
                .fontSize(30)
                .fontWeight(FontWeight.Regular)
            }
          }.justifyContent(FlexAlign.Start)


        }.id("下行左列")
        //.width('%')
        .height('60%')
        .padding(5)
        .border({ width: 2, color: Color.Black, radius: 10, style: BorderStyle.Solid })



        // Row(){
        //   //下行右列
        //   Column() {
        //     Row() {
        //
        //       Button('下一页').onClick(() => { //页面跳转
        //         router.pushUrl({ url: 'pages/Page2' })
        //       })
        //
        //     }
        //   }
        //
        // }.id('下行右列')
        // .width('10%')
        // .height('100%')
        // .justifyContent(FlexAlign.End)
        // .alignItems(VerticalAlign.Bottom)
        // .padding(10)
        // .backgroundColor(Color.Red)

      }.id('下行')
      .width('100%')
      .height('25%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Bottom)
      //.backgroundColor(Color.Pink)



    }.width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)//7ECFF9FA
    .backgroundColor("#f7f6f0d3")




  }

}