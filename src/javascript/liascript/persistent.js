'use strict'

function swapElements (obj1, obj2) {
  // create marker element and insert it where obj1 is
  var temp = document.createElement('div')
  obj1.parentNode.insertBefore(temp, obj1)

  // move obj1 to right before obj2
  obj2.parentNode.insertBefore(obj1, obj2)

  // move obj2 to right before where obj1 used to be
  temp.parentNode.insertBefore(obj2, temp)

  // remove temporary marker node
  temp.parentNode.removeChild(temp)
}

var persistent = {
  bag: document.createElement('div'),
  section: -1,

  store: function (section) {
    if (section === this.section) return

    this.section = section
    let elements = document.getElementsByClassName('persistent')
    for (var e of elements) {
      let temp = document.createElement('span')
      this.bag.appendChild(temp)
      swapElements(temp, e)
    }
  },

  load: function (section) {
    let elements = document.getElementsByClassName('persistent')

    for (var e of elements) {
      for (var b of this.bag.childNodes) {
        if (b.id === e.id) {
          e.replaceWith(b)
          break
        }
      }
    }
  }
}

export {
  persistent
}
