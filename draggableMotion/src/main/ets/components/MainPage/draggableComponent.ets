/*
Copyright [2022] [Application library engineering group]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import Curves from '@ohos.curves'
import { Cell } from './DraggableTypes'
import { DraggableModel } from './DraggableModel'

const springSetting1: string = Curves.spring(0, 1, 180, 10)
const springSetting2: string = Curves.spring(0, 1, 120, 15)

@Component
export struct Draggable {
  model: DraggableModel.Model = undefined
  private mouseXY: number[] = [0, 0]
  private positionOffsetCorrection: number[] = [0, 0]
  @State private lastPress: number = undefined
  @State private isPressed: boolean = false
  @State private scale: number = 1
  @State private order: number[] = undefined
  private innerFlexSize: SizeOptions = undefined
  private layout: Cell[] = undefined
  private ballCount: number
  private cellWidth: number
  private cellHeight: number

  aboutToAppear() {
    if (this.model == undefined || this.model == null
        || this.model.getBallSize() == null || this.model.getBallSize() == undefined
        || this.model.getColorsList() == null || this.model.getColorsList() == undefined) {
      console.error('Please pass correct model to the Draggable component');
      return;
    }
    this.ballCount = this.model.getColorsList().length
    this.cellWidth = DraggableModel.Model.len2num(this.model.getBallSize().width) + 20
    this.cellHeight = DraggableModel.Model.len2num(this.model.getBallSize().height) + 40

    this.order = Array.from(Array(this.ballCount).keys())
    this.innerFlexSize = {
      width: this.model.getColumns() * this.cellWidth - 20,
      height: Math.ceil(this.model.getColorsList().length / this.model.getColumns()) * this.cellHeight - 40,
    }

    this.layout = Array.from(Array(this.ballCount).keys()).map(n => {
      var columnCnt = this.model.getColumns()
      const row = Math.floor(n / columnCnt);
      const col = n % columnCnt;
      return { x: this.cellWidth * col, y: this.cellHeight * row };
    });
  }

  private reinsert(arr, from, to) {
    const _arr = arr.slice(0);
    const val = _arr[from];
    _arr.splice(from, 1);
    _arr.splice(to, 0, val);
    return _arr;
  }

  private nearestBallIndex() {
    var psuedoCol = Math.floor(this.mouseXY[0] / this.cellWidth)
    var psuedoRow = Math.floor(this.mouseXY[1] / this.cellHeight)
    var col = (psuedoCol >= 0 && psuedoCol < this.model.getColumns()) ? psuedoCol : this.model.getColumns() - 1;
    var row = (psuedoRow >= 0 && psuedoRow < Math.ceil(this.ballCount / this.model.getColumns())) ? psuedoRow : Math.ceil(this.ballCount / this.model.getColumns()) - 1;
    if (psuedoCol < 0) col = 0
    if (psuedoRow < 0) row = 0
    return row * this.model.getColumns() + col
  }

  private shadowXOffset(key: number): number {
    var x = this.layout[this.order.indexOf(key)].x
    if (this.lastPress === key && this.isPressed) {
      x = this.mouseXY[0]
    }

    return (x - (3 * this.cellWidth - 50) / 2) / 10
  }

  private touchDownHandler = (key: number) => {
    this.lastPress = key
    this.isPressed = true
    const index = this.order.indexOf(key)
    this.mouseXY = [this.layout[index].x, this.layout[index].y]

    animateTo({
      duration: 1000,
      curve: springSetting1
    }, () => {
      this.scale = 1.2
    })
  }
  private touchUpHandler = (key: number) => {
    animateTo({
      duration: 1000,
      curve: springSetting1
    }, () => {
      this.scale = 1
    })

    this.isPressed = false
  }
  private dragMoveHandler = ({pageX, pageY}) => {
    if (this.isPressed) {
      const mouseXY = [pageX - this.positionOffsetCorrection[0], pageY - this.positionOffsetCorrection[1]]
      const index = this.nearestBallIndex()
      const newOrder = this.reinsert(this.order, this.order.indexOf(this.lastPress), index);

      this.mouseXY = mouseXY
      this.order = newOrder
    }
  }
  private dropEventHandler = () => {
    this.isPressed = false
  };

  build() {
    if (this.model != undefined && this.model != null) {
      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          ForEach(this.order,
            (_, key: number) => {

              Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                Text(`${this.model.getLabelTextList()[key]}`).fontSize(20)
              }
              .size(this.model.getBallSize())
              .backgroundColor(this.model.getColorsList()[key])
              .position({ x: 0, y: 0 })
              .translate((this.lastPress === key && this.isPressed) ? {
                                                                        x: this.mouseXY[0],
                                                                        y: this.mouseXY[1],
                                                                        z: 0
                                                                      } : {
                                                                            x: this.layout[this.order.indexOf(key)].x,
                                                                            y: this.layout[this.order.indexOf(key)].y,
                                                                            z: 0
                                                                          })
              .border({ radius: 99, width: 1, color: Color.Black, style: BorderStyle.Solid })
              .zIndex((this.lastPress === key) ? 99 : this.order.indexOf(key))
              .scale({
                x: (this.lastPress === key && this.isPressed) ? this.scale : 1,
                y: (this.lastPress === key && this.isPressed) ? this.scale : 1,
                centerX: '50%',
                centerY: '50%'
              })
              .shadow({
                offsetX: this.shadowXOffset(key),
                ...this.model.getShadowOptions()
              })
              .onTouch((e) => {
                if (e.type == TouchType.Down) {
                  this.touchDownHandler(key)
                }
                if (e.type == TouchType.Up) {
                  this.touchUpHandler(key)
                }
              })
              .animation({
                duration: (this.lastPress === key && this.isPressed) ? 0 : 1000,
                curve: springSetting2
              })
            }
          )
        }
        .size(this.innerFlexSize)
        .onAreaChange((_, newArea) => {
          this.positionOffsetCorrection = [parseFloat(newArea.globalPosition.x.toString()) + 25, parseFloat(newArea.globalPosition.y.toString()) + 25]
        })
      }
      .width('100%')
      .height('100%')
      .onDragStart((e) => {
        this.dragMoveHandler({ pageX: e.getX(), pageY: e.getY() })
      })
      .onDragMove((e) => {
        this.dragMoveHandler({ pageX: e.getX(), pageY: e.getY() })
      })
      .onDrop(() => {
        this.dropEventHandler()
      })
    }
  }
}

export { DraggableModel } from './DraggableModel'
