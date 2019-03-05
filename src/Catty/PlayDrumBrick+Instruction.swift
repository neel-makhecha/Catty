/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

@objc extension PlayDrumBrick: CBInstructionProtocol {

    @nonobjc func instruction(audioEngine: AudioEngine) -> CBInstruction {
        guard let spriteObject = self.script?.object else { fatalError("This should never happen") }
        let spriteObjectName = spriteObject.name

        return CBInstruction.waitExecClosure { context, _ in
            let waitUntilNoteFinished = NSCondition()
            waitUntilNoteFinished.accessibilityHint = "0"

            let durationInBeats = context.formulaInterpreter.interpretDouble(self.duration, for: spriteObject)
            let durationTimer = Timer.init(timeInterval: AudioEngineConfig.DEFAULT_INTERVAL,
                                           target: self,
                                           selector: #selector(PlayDrumBrick.noteOff(timer:)),
                                           userInfo: waitUntilNoteFinished,
                                           repeats: false)
            let note = Note(pitch: self.drumChoice,
                            beats: durationInBeats,
                            bpm: audioEngine.bpm,
                            durationTimer: durationTimer,
                            isPause: false)
            audioEngine.playDrum(note: note, key: spriteObjectName!)

            waitUntilNoteFinished.lock()
            while waitUntilNoteFinished.accessibilityHint == "0" { //accessibilityHint used because synthesizer.speaking not yet true.
                waitUntilNoteFinished.wait()
            }
            waitUntilNoteFinished.unlock()
            audioEngine.stopDrum(pitch: self.drumChoice, key: spriteObjectName!)
            audioEngine.activeNotes.remove(note)
        }
    }

    func noteOff(timer: Timer) {
        let condition = timer.userInfo as! NSCondition
        condition.accessibilityHint = "1"
        condition.signal()
    }
}
