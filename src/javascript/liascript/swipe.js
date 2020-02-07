function swipedetect(el, callback){

  var touchsurface = el,
      swipedir,
      startX,
      startY,
      distX,
      distY,
      dist,
      threshold = 150,
      restraint = 100,
      allowedTime = 300,
      elapsedTime,
      startTime,
      ismousedown = false,
      detecttouch = !!('ontouchstart' in window) || !!('ontouchstart' in document.documentElement) || !!window.ontouchstart || !!window.Touch || !!window.onmsgesturechange || (window.DocumentTouch && window.document instanceof window.DocumentTouch),
      handleswipe = callback || function(swipedir){}

  function isContained(m, e) {
    e = e || window.event
    let c=/(click)|(mousedown)|(mouseup)/i.test(e.type)? e.target : ( e.relatedTarget || ((e.type=="mouseover")? e.fromElement : e.toElement) )

    while (c && c!=m) {
      try {
        c=c.parentNode
      } catch(e) {
        c=m
      }
    }

    return c==m
}

  touchsurface.addEventListener('touchstart', function(e){
    var touchobj = e.changedTouches[0]
        swipedir = 'none'
        dist = 0
        startX = touchobj.pageX
        startY = touchobj.pageY
        startTime = new Date().getTime() // record time when finger first makes contact with surface
    e.preventDefault()
  }, { passive: true })

  touchsurface.addEventListener('touchmove', function(e){
    e.preventDefault() // prevent scrolling when inside DIV
  }, { passive: true })

  touchsurface.addEventListener('touchend', function(e){
    var touchobj = e.changedTouches[0]
        distX = touchobj.pageX - startX // get horizontal dist traveled by finger while in contact with surface
        distY = touchobj.pageY - startY // get vertical dist traveled by finger while in contact with surface
        elapsedTime = new Date().getTime() - startTime // get time elapsed
    if (elapsedTime <= allowedTime){ // first condition for awipe met
      if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint){ // 2nd condition for horizontal swipe met
        swipedir = (distX < 0)? 'left' : 'right'
      }
      else if (Math.abs(distY) >= threshold  && Math.abs(distX) <= restraint){ // 2nd condition for vertical swipe met
        swipedir = (distY < 0)? 'up' : 'down'
      }
    }
    // check that elapsed time is within specified, horizontal dist traveled >= threshold, and vertical dist traveled <= 100
    handleswipe(swipedir)
    e.preventDefault()
  }, { passive: true })

  if (!detecttouch){
    document.body.addEventListener('mousedown', function(e){
      if ( isContained(touchsurface, e) ){
        var touchobj = e
            swipedir = 'none'
            dist = 0
            startX = touchobj.pageX
            startY = touchobj.pageY
            startTime = new Date().getTime() // record time when finger first makes contact with surface
            ismousedown = true
        e.preventDefault()
      }
    }, { passive: true })

    document.body.addEventListener('mousemove', function(e){
      e.preventDefault() // prevent scrolling when inside DIV
    }, { passive: true })

    document.body.addEventListener('mouseup', function(e){
      if (ismousedown){
        var touchobj = e
            distX = touchobj.pageX - startX // get horizontal dist traveled by finger while in contact with surface
            distY = touchobj.pageY - startY // get vertical dist traveled by finger while in contact with surface
            elapsedTime = new Date().getTime() - startTime // get time elapsed
        if (elapsedTime <= allowedTime){ // first condition for awipe met
          if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint){ // 2nd condition for horizontal swipe met
            swipedir = (distX < 0)? 'left' : 'right'
          }
          else if (Math.abs(distY) >= threshold  && Math.abs(distX) <= restraint){ // 2nd condition for vertical swipe met
            swipedir = (distY < 0)? 'up' : 'down'
          }
        }
        // check that elapsed time is within specified, horizontal dist traveled >= threshold, and vertical dist traveled <= 100
        handleswipe(swipedir)
        ismousedown = false
        e.preventDefault()
      }
    }, { passive: true })
  }
};

export {
  swipedetect
}
