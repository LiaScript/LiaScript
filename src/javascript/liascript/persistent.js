function swapElements (obj1, obj2) {
  // create marker element and insert it where obj1 is
  const temp = document.createElement('div')
  obj1.parentNode.insertBefore(temp, obj1)

  // move obj1 to right before obj2
  obj2.parentNode.insertBefore(obj1, obj2)

  // move obj2 to right before where obj1 used to be
  temp.parentNode.insertBefore(obj2, temp)

  // remove temporary marker node
  temp.parentNode.removeChild(temp)
}

const persistent = {
  bag: document.createElement('div'),
  section: -1,

  store: function (section) {
    if (section === this.section) return

    this.section = section
    const elements = document.getElementsByClassName('persistent')
    for (const e of elements) {
      const temp = document.createElement('span')
      this.bag.appendChild(temp)
      swapElements(temp, e)
    }
  },

  load: function (section) {
    const elements = document.getElementsByClassName('persistent')

    for (const e of elements) {
      for (const b of this.bag.childNodes) {
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
