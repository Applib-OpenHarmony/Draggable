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

namespace DraggableModel {
  interface ShadowOptions {
    radius : number | Resource
    offsetY : number | Resource
    color : Color | string | Resource
  }

  const DEFAULT_SHADOW_OPTIONS : ShadowOptions = {radius : 10, offsetY : 10, color : 'rgba(0,0,0,0.5)'}

  export class Model {
    private columns : number
    private colorsList : string[]
    private shadowOptions : ShadowOptions
    private labelTextList : string[]
    private ballSize : SizeOptions

    constructor(columns : number , ballSize : SizeOptions, colorsList : string[], shadowOptions? : ShadowOptions, labelTextList? : string[]) {
      this.setColumns(columns)
      this.setBallSize(ballSize)
      this.setColorsList(colorsList)
      this.setShadowOptions( (shadowOptions)? shadowOptions : DEFAULT_SHADOW_OPTIONS)
      this.setLabelTextList( (labelTextList)? labelTextList : this.createDefaultTextList())
    }

    setColumns(columns : number) : Model {
      if(columns == undefined || columns == null) {
        console.error('Give valid input for columns( number )')
        return
      }
      else {
        this.columns = columns
      }
      return this
    }

    getColumns() : number {
      return this.columns
    }

    setBallSize(ballSize : SizeOptions) : Model {
      if(ballSize == undefined || ballSize == null) {
        console.error('Give valid input for ballSize')
        return
      }
      else {
        this.ballSize = ballSize
      }
      return this
    }

    getBallSize() : SizeOptions {
      return this.ballSize
    }

    setColorsList(colorsList : string[]) : Model {
      if(colorsList == undefined || colorsList == null) {
        console.error('Give valid input for colorsList')
        return
      }
      else {
        this.validateColorsListLength(colorsList)
        this.colorsList = colorsList
      }
      return this
    }

    getColorsList() : string[] {
      return this.colorsList
    }

    setShadowOptions(shadowOptions : ShadowOptions) : Model {
      if(shadowOptions == undefined || shadowOptions == null) {
        console.error('Give valid input for shadowOptions')
        this.shadowOptions = DEFAULT_SHADOW_OPTIONS
      }
      else {
        this.shadowOptions = shadowOptions
      }
      return this
    }

    getShadowOptions() : ShadowOptions {
      return this.shadowOptions
    }

    setLabelTextList(labelTextList : string[]) : Model {
      if(labelTextList == undefined || labelTextList == null) {
        console.error('Give valid input for labelTextList')
        this.labelTextList = this.createDefaultTextList()
      }
      else {
        this.labelTextList = labelTextList
      }
      return this
    }

    getLabelTextList() : string[] {
      return this.labelTextList
    }

    private validateColorsListLength(colorsList : string[]) : void {
      if (colorsList.length < this.columns){
        console.error('colorsList length should be >= columns')
      }
    }

    static len2num(value : Length) : number {
      return parseFloat(value.toString())
    }

    private createDefaultTextList() : string[] {
      var _defaultList :string[] = []
      for(var i = 0; i < this.colorsList.length; i++) {
        _defaultList.splice(i, 0, '')
      }
      return _defaultList
    }

  }
}

export { DraggableModel }