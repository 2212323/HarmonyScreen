import ble from "@ohos.bluetooth.ble"
import { BusinessError } from '@ohos.base'

const minRssi = -200

@Entry
@Component
struct BLE {
  @State message: string = 'Hello BLE'
  @State receivedText: string = 'No Data Received'
  @State availableDevices: Array<ble.ScanResult> = [] //能查到的设备

  addData(data: ble.ScanResult): void {
    let bFind = false
    this.availableDevices.forEach(element => {
      if (!bFind && element.deviceId == data.deviceId) {
        //console.info('BLE scan update ' + data.deviceId + ' rssi:' + element.rssi + ' ==> ' + data.rssi)
        element.rssi = data.rssi
        bFind = true
      }
    })
    if (!bFind) {
      //console.info('BLE scan add ' + data.deviceId + ' count:' + this.availableDevices.length)
      this.availableDevices.push(data)//把能查到的设备存入availableDevices
      this.message = 'BLE count:' + this.availableDevices.length

      // 处理接收到的数据
      const manufacturerData = this.getManufacturerSpecificData(data.data)
      if (manufacturerData) {
        this.receivedText = this.arrayBufferToString(manufacturerData)
      }
    }
  }

  getManufacturerSpecificData(data: ArrayBuffer): ArrayBuffer | null {
    // 假设制造商数据位于广告数据的特定位置，这需要根据您的实现进行调整
    // 例如，制造商数据通常以特定的标识符开头
    // 以下示例代码假设制造商数据在 data 中的位置
    const manufacturerIdentifier = new Uint8Array([0x12, 0x34])
    const dataArray = new Uint8Array(data)
    for (let i = 0; i < dataArray.length - manufacturerIdentifier.length; i++) {
      if (dataArray.slice(i, i + manufacturerIdentifier.length).every((value, index) => value === manufacturerIdentifier[index])) {
        return data.slice(i + manufacturerIdentifier.length)
      }
    }
    return null
  }

  arrayBufferToString(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer)
    let result = ''
    for (let i = 0; i < bytes.length; i++) {
      result += String.fromCharCode(bytes[i])
    }
    return result
  }

  openBle(): void {
    try {
      ble.on("BLEDeviceFind", (data: Array<ble.ScanResult>) => {
        let i = 0
        data.forEach(element => {
          //console.info('BLE scan device[' + i + '] deviceId = ' + element["deviceId"] +
          //' name = ' + element["deviceName"] +
          //' rssi = ' + element["rssi"] +
          //' data[' + element["data"].byteLength + '] = ' +
          //this.arrayBufferToString(element["data"]))
          if (element.rssi > minRssi && element.deviceName != '') {
            this.addData(element)
          }
          i++
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





  build() {
    Row() {
      Column() {

        Text(this.message)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)

        Text(this.receivedText)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Button() {
          Text('ble start')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .backgroundColor('#0D9FFB')
        .width('30%')
        .height('10%')
        .onClick(() => {
          this.openBle()
        })

        Button() {
          Text('ble stop')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .backgroundColor('#0D9FFB')
        .width('30%')
        .height('10%')
        .onClick(() => {
          this.availableDevices = []
          this.message = 'Hello BLE'
          this.receivedText = 'No Data Received'
          try {
            ble.off('BLEDeviceFind')
            ble.stopBLEScan()
          } catch (err) {
            console.error("ble errCode:" + (err as BusinessError).code + ",errMessage:" + (err as BusinessError).message)
          }
        })

        List({ space: "4vp", initialIndex: 0 }) {
          ForEach(this.availableDevices, (item: ble.ScanResult, index: number) => {
            ListItemGroup() {
              ListItem() {
                Text('[' + index.toString(10) + "]" + item.deviceId)
                  .textAlign(TextAlign.Center)
                  .fontSize(30)
                  .backgroundColor(Color.Yellow)
                  .width('100%')
              }
              ListItem() {
                Text('    name:' + item.deviceName)
                  .textAlign(TextAlign.Start)
                  .fontSize(30)
                  .backgroundColor(Color.Orange)
                  .width('100%')
              }

              ListItem() {
                Text('    rssi:' + item.rssi.toString(10))
                  .textAlign(TextAlign.Start)
                  .fontSize(30)
                  .backgroundColor(Color.Orange)
                  .width('100%')
              }

              ListItem() {
                Text('    connectable:' + item.connectable)
                  .textAlign(TextAlign.Start)
                  .fontSize(30)
                  .backgroundColor(Color.Orange)
                  .width('100%')
              }

              ListItem() {
                Text('    data:' + this.arrayBufferToString(item.data))
                  .textAlign(TextAlign.Start)
                  .fontSize(30)
                  .backgroundColor(Color.Orange)
                  .width('100%')
              }


            }
          })
        }
        .layoutWeight(10)
        .backgroundColor(0xDCDCDC)
        .height('50%')
        .width('60%')
        .margin({ top: 20 })
      }
      .width('100%')
    }
    .height('100%')
  }
}
