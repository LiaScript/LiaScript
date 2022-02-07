import log from '../log'

var bag = document.createElement('div')
var section = -1

const Service = {
  PORT: 'persistent',

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'store':
        store(event.message.param)
        break
      case 'load':
        load()
        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

function store(current_section: number) {
  if (current_section === section) return

  section = current_section
  const elements = document.getElementsByClassName('persistent')
  for (const e of elements) {
    const temp = document.createElement('span')
    bag.appendChild(temp)
    swapElements(temp, e)
  }
}

function load() {
  const elements = document.getElementsByClassName('persistent')

  for (const e of elements) {
    // TODO: check for correctness ... removed because of ts warning
    // for (const b of this.bag.childNodes) {
    for (const b of bag.children) {
      if (b.id === e.id) {
        e.replaceWith(b)
        break
      }
    }
  }
}

function swapElements(obj1: Element, obj2: Element) {
  // create marker element and insert it where obj1 is
  const temp = document.createElement('div')

  if (obj1.parentNode) obj1.parentNode.insertBefore(temp, obj1)

  // move obj1 to right before obj2
  if (obj2.parentNode) obj2.parentNode.insertBefore(obj1, obj2)

  // move obj2 to right before where obj1 used to be
  if (temp.parentNode) {
    temp.parentNode.insertBefore(obj2, temp)

    // remove temporary marker node
    temp.parentNode.removeChild(temp)
  }
}

export default Service
