var findAPITries = 0

// source: https://scorm.com/scorm-explained/technical-scorm/run-time/api-discovery-algorithms/
function findAPI(win) {
  // Check to see if the window (win) contains the API
  // if the window (win) does not contain the API and
  // the window (win) has a parent window and the parent window
  // is not the same as the window (win)
  while (win.API == null && win.parent != null && win.parent != win) {
    // increment the number of findAPITries
    findAPITries++

    // Note: 7 is an arbitrary number, but should be more than sufficient
    if (findAPITries > 7) {
      alert('Error finding API -- too deeply nested.')
      return null
    }

    // set the variable that represents the window being
    // being searched to be the parent of the current window
    // then search for the API again
    win = win.parent
  }
  return win.API
}

export function getAPI() {
  // start by looking for the API in the current window
  var theAPI = findAPI(window)

  // if the API is null (could not be found in the current window)
  // and the current window has an opener window
  if (
    theAPI == null &&
    window.opener != null &&
    typeof window.opener != 'undefined'
  ) {
    // try to find the API in the current window’s opener
    theAPI = findAPI(window.opener)
  }
  // if the API has not been found
  if (theAPI == null) {
    // Alert the user that the API Adapter could not be found
    alert('Unable to find the SCORM1.2 API adapter')
  }
  return theAPI
}
