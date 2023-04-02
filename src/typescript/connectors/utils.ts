const short = {
  SingleChoice: 'sc',
  MultipleChoice: 'mc',
  Text: 'tx',
  Select: 'st',
  Matrix: 'mx',
  Generic: 'gn',
  error_msg: 'err',
}

// return the key value pair order, this way only short has to be defined once
const long = Object.entries(short).reduce((acc, [key, value]) => {
  acc[value] = key
  return acc
}, {})

function renameJsonKeys(jsonObject: any, replacements: Object) {
  if (typeof jsonObject !== 'object' || jsonObject === null) {
    return jsonObject
  }

  if (Array.isArray(jsonObject)) {
    return jsonObject.map((element) => renameJsonKeys(element, replacements))
  }

  const modifiedObject = {}
  for (const [key, value] of Object.entries(jsonObject)) {
    const newKey = replacements[key] || key
    modifiedObject[newKey] = renameJsonKeys(value, replacements)
  }
  return modifiedObject
}

export function encodeJSON(json: any) {
  return JSON.stringify(renameJsonKeys(json, short))
}

export function decodeJSON(json: string) {
  return renameJsonKeys(JSON.parse(json), long)
}

/**
 * A simple json-parser that does not trow an error, but returns null if it fails
 * @param string - a valid JSON representation
 */
export function jsonParse(json: string) {
  try {
    return JSON.parse(json)
  } catch (e) {}
  return null
}

/**
 * Compare Object state information for quizzes, surveys, and tasks
 * @param a
 * @param b
 * @returns true if not equal otherwise false
 */
export function neq(a: any, b: any) {
  return JSON.stringify(a) != JSON.stringify(b)
}
