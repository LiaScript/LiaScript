declare global {
  interface Window {
    API?: SCORM
  }
}

export type SCORM = {
  /**
   * Begins a communication session with the LMS.
   */
  LMSInitialize: (_: Empty) => boolean

  /**
   * Ends a communication session with the LMS.
   */
  LMSFinish: (_: Empty) => boolean

  /**
   *  Retrieves a value from the LMS.
   */
  LMSGetValue: (element: CMIElement) => string

  /**
   * Saves a value to the LMS.
   */
  LMSSetValue: (element: CMIElement, value: string) => string

  /**
   * Indicates to the LMS that all data should be persisted (not required).
   */
  LMSCommit: (_: Empty) => void

  /**
   * Returns the error code that resulted from the last API call.
   */
  LMSGetLastError: () => string | null

  /**
   * Returns a short string describing the specified error code.
   */
  LMSGetErrorString: (errorCode: CMIErrorCode) => string

  /**
   * Returns detailed information about the last error that occurred.
   */
  LMSGetDiagnostic: (errorCode: CMIErrorCode) => string
}

type Empty = ''

export type CMIElement =
  | 'cmi.core._children' // (student_id, student_name, lesson_location, credit, lesson_status, entry, score, total_time, lesson_mode, exit, session_time, RO) Listing of supported data model elements
  | 'cmi.core.student_id' // (CMIString (SPM: 255), RO) Identifies the student on behalf of whom the SCO was launched
  | 'cmi.core.student_name' // (CMIString (SPM: 255), RO) Name provided for the student by the LMS
  | 'cmi.core.lesson_location' // (CMIString (SPM: 255), RW) The learner’s current location in the SCO
  | 'cmi.core.credit' // (“credit”, “no-credit”, RO) Indicates whether the learner will be credited for performance in the SCO
  | 'cmi.core.lesson_status' // (“passed”, “completed”, “failed”, “incomplete”, “browsed”, “not attempted”, RW) Indicates whether the learner has completed and satisfied the requirements for the SCO
  | 'cmi.core.entry' // (“ab-initio”, “resume”, “”, RO) Asserts whether the learner has previously accessed the SCO
  | 'cmi.core.score_children' // (raw,min,max, RO) Listing of supported data model elements
  | 'cmi.core.score.raw' // (CMIDecimal, RW) Number that reflects the performance of the learner relative to the range bounded by the values of min and max
  | 'cmi.core.score.max' // (CMIDecimal, RW) Maximum value in the range for the raw score
  | 'cmi.core.score.min' // (CMIDecimal, RW) Minimum value in the range for the raw score
  | 'cmi.core.total_time' // (CMITimespan, RO) Sum of all of the learner’s session times accumulated in the current learner attempt
  | 'cmi.core.lesson_mode' // (“browse”, “normal”, “review”, RO) Identifies one of three possible modes in which the SCO may be presented to the learner
  | 'cmi.core.exit' // (“time-out”, “suspend”, “logout”, “”, WO) Indicates how or why the learner left the SCO
  | 'cmi.core.session_time' // (CMITimespan, WO) Amount of time that the learner has spent in the current learner session for this SCO
  | 'cmi.suspend_data' // (CMIString (SPM: 4096), RW) Provides space to store and retrieve data between learner sessions
  | 'cmi.launch_data' // (CMIString (SPM: 4096), RO) Data provided to a SCO after launch, initialized from the dataFromLMS manifest element
  | 'cmi.comments' // (CMIString (SPM: 4096), RW) Textual input from the learner about the SCO
  | 'cmi.comments_from_lms' // (CMIString (SPM: 4096), RO) Comments or annotations associated with a SCO
  | 'cmi.objectives._children' // (id,score,status, RO) Listing of supported data model elements
  | 'cmi.objectives._count' // (non-negative integer, RO) Current number of objectives being stored by the LMS
  | `cmi.objectives.${number}.id` // (CMIIdentifier, RW) Unique label for the objective
  | `cmi.objectives.${number}.score._children` // (raw,min,max, RO) Listing of supported data model elements
  | `cmi.objectives.${number}.score.raw` // (CMIDecimal, RW) Number that reflects the performance of the learner, for the objective, relative to the range bounded by the values of min and max
  | `cmi.objectives.${number}.score.max` // (CMIDecimal, Rw) Maximum value, for the objective, in the range for the raw score
  | `cmi.objectives.${number}.score.min` // (CMIDecimal, RW) Minimum value, for the objective, in the range for the raw score
  | `cmi.objectives.${number}.status` // (“passed”, “completed”, “failed”, “incomplete”, “browsed”, “not attempted”, RW) Indicates whether the learner has completed or satisfied the objective
  | 'cmi.student_data._children' // (mastery_score, max_time_allowed, time_limit_action, RO) Listing of supported data model elements
  | 'cmi.student_data.mastery_score' // (CMIDecimal, RO) Passing score required to master the SCO
  | 'cmi.student_data.max_time_allowed' // (CMITimespan, RO) Amount of accumulated time the learner is allowed to use a SCO
  | 'cmi.student_data.time_limit_action' // (exit,message,” “exit,no message”,” continue,message”, “continue, no message”, RO) Indicates what the SCO should do when max_time_allowed is exceeded
  | 'cmi.student_preference._children' // (audio,language,speed,text, RO) Listing of supported data model elements
  | 'cmi.student_preference.audio' // (CMISInteger, RW) Specifies an intended change in perceived audio level
  | 'cmi.student_preference.language' // (CMIString (SPM: 255), RW) The student’s preferred language for SCOs with multilingual capability
  | 'cmi.student_preference.speed' // (CMISInteger, RW) The learner’s preferred relative speed of content delivery
  | 'cmi.student_preference.text' // (CMISInteger, RW) Specifies whether captioning text corresponding to audio is displayed
  | 'cmi.interactions._children' // (id,objectives,time,type,correct_responses,weighting,student_response,result,latency, RO) Listing of supported data model elements
  | 'cmi.interactions._count' // (CMIInteger, RO) Current number of interactions being stored by the LMS
  | `cmi.interactions.${number}.id` // (CMIIdentifier, WO) Unique label for the interaction
  | `cmi.interactions.${number}.objectives._count` // (CMIInteger, RO) Current number of objectives (i.e., objective identifiers) being stored by the LMS for this interaction
  | `cmi.interactions.${number}.objectives.${number}.id` // (CMIIdentifier, WO) Label for objectives associated with the interaction
  | `cmi.interactions.${number}.time` // (CMITime, WO) Point in time at which the interaction was first made available to the student for student interaction and response
  | `cmi.interactions.${number}.type` // (“true-false”, “choice”, “fill-in”, “matching”, “performance”, “sequencing”, “likert”, “numeric”, WO) Which type of interaction is recorded
  | `cmi.interactions.${number}.correct_responses._count` // (CMIInteger, RO) Current number of correct responses being stored by the LMS for this interaction
  | `cmi.interactions.${number}.correct_responses.${number}.pattern` // (format depends on interaction type, WO) One correct response pattern for the interaction
  | `cmi.interactions.${number}.weighting` // (CMIDecimal, WO) Weight given to the interaction relative to other interactions
  | `cmi.interactions.${number}.student_response` // (format depends on interaction type, WO) Data generated when a student responds to an interaction
  | `cmi.interactions.${number}.result` // (“correct”, “wrong”, “unanticipated”, “neutral”, “x.x [CMIDecimal]”, WO) Judgment of the correctness of the learner response
  | `cmi.interactions.${number}.latency` // (CMITimespan, WO) Time elapsed between the time the interaction was made available to the learner for response and the time of the first response

export type CMIErrorCode = string | null
