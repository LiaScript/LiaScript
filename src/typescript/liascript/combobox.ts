// Keyboard handling of the select-only comboboxes of LiaScript (`.lia-dropdown`,
// see the WAI-ARIA authoring practices). Elm renders the markup and handles all
// clicks, the keys only move the active option and click the existing elements,
// thus it works for Elm-handlers as well as for the string-handlers of inline
// quizzes. The focus remains on the combobox.

const ACTIVE = 'is-active'

function getOptions(combobox: HTMLElement): HTMLElement[] {
  const listbox = document.getElementById(
    combobox.getAttribute('aria-controls') || ''
  )

  return listbox
    ? Array.prototype.slice.call(listbox.querySelectorAll('[role=option]'))
    : []
}

function setActive(combobox: HTMLElement, options: HTMLElement[], index: number) {
  options.forEach((option, i) => {
    if (i === index) option.classList.add(ACTIVE)
    else option.classList.remove(ACTIVE)
  })

  const option = options[index]

  if (!option) {
    combobox.removeAttribute('aria-activedescendant')
    return
  }

  combobox.setAttribute('aria-activedescendant', option.id)

  // scrollIntoView with options throws on old Gecko (KaiOS)
  const listbox = option.parentElement
  if (listbox) {
    const top = option.getBoundingClientRect().top
    const bounds = listbox.getBoundingClientRect()

    if (top < bounds.top) {
      listbox.scrollTop -= bounds.top - top
    } else if (top + option.offsetHeight > bounds.bottom) {
      listbox.scrollTop += top + option.offsetHeight - bounds.bottom
    }
  }
}

function indexOf(options: HTMLElement[], predicate: (o: HTMLElement) => boolean) {
  for (let i = 0; i < options.length; i++) {
    if (predicate(options[i])) return i
  }
  return -1
}

// Elm renders the opened list with the next animation frame
function afterRender(fn: () => void) {
  setTimeout(fn, 50)
}

const FOCUSABLE =
  'a[href],button,input,select,textarea,[tabindex]:not([tabindex="-1"])'

// A choice might replace the whole form, e.g. the classroom backend, then the
// focus moves to the new combobox or to the first element of the dialog
function keepFocus(combobox: HTMLElement) {
  const controls = combobox.getAttribute('aria-controls')
  const container = combobox.closest('lia-modal, .lia-quiz, main')

  afterRender(() => {
    if (document.body.contains(combobox)) return

    const next =
      (controls &&
        (document.querySelector(
          '[role=combobox][aria-controls="' + controls + '"]'
        ) as HTMLElement | null)) ||
      (container && document.body.contains(container)
        ? (container.querySelector(FOCUSABLE) as HTMLElement | null)
        : null)

    next?.focus()
  })
}

document.addEventListener('keydown', (event: KeyboardEvent) => {
  const combobox = event.target as HTMLElement

  if (
    !combobox ||
    !combobox.matches ||
    !combobox.matches('.lia-dropdown [role=combobox]') ||
    combobox.getAttribute('aria-disabled') === 'true' ||
    event.altKey ||
    event.ctrlKey ||
    event.metaKey
  ) {
    return
  }

  const open = combobox.getAttribute('aria-expanded') === 'true'
  const options = getOptions(combobox)

  let index = indexOf(options, (o) => o.classList.contains(ACTIVE))
  if (index < 0) {
    index = indexOf(options, (o) => o.getAttribute('aria-selected') === 'true')
  }

  if (!open) {
    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowUp':
      case 'Home':
      case 'End':
      case 'Enter':
      case ' ':
        combobox.click()
        afterRender(() => {
          const options = getOptions(combobox)
          const selected = indexOf(
            options,
            (o) => o.getAttribute('aria-selected') === 'true'
          )
          setActive(combobox, options, selected < 0 ? 0 : selected)
        })
        break

      default:
        return
    }
  } else {
    switch (event.key) {
      case 'ArrowDown':
        setActive(combobox, options, Math.min(index + 1, options.length - 1))
        break

      case 'ArrowUp':
        setActive(combobox, options, Math.max(index - 1, 0))
        break

      case 'Home':
        setActive(combobox, options, 0)
        break

      case 'End':
        setActive(combobox, options, options.length - 1)
        break

      case 'Enter':
      case ' ':
        if (options[index]) {
          options[index].click()
          keepFocus(combobox)
        } else {
          combobox.click()
        }
        setActive(combobox, options, -1)
        break

      case 'Escape':
        combobox.click()
        setActive(combobox, options, -1)
        break

      case 'Tab':
        // close, but let the focus move on
        combobox.click()
        setActive(combobox, options, -1)
        return

      default:
        return
    }
  }

  event.preventDefault()
  event.stopPropagation()
}, true) // capture: Escape must not close a surrounding modal as well
