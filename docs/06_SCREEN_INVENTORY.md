# 06 — Exhaustive Mobile Screen Inventory

Every full screen, sheet, overlay, loading, empty and error state below must be represented in design specs and tested.

## Onboarding
ONB-01 Splash/loading
ONB-02 Welcome
ONB-03 Language selection
ONB-04 Privacy/local-processing explanation
ONB-05 Media permission explanation
ONB-06 Camera permission explanation
ONB-07 Microphone permission explanation
ONB-08 First-project tutorial
ONB-09 Tutorial success
ONB-10 Permission denied recovery

## Home
HOME-01 Home
HOME-02 Empty home
HOME-03 Recent projects
HOME-04 Continue editing
HOME-05 Quick create sheet
HOME-06 Improve a video
HOME-07 Template preview
HOME-08 Offline home

## Projects/library
LIB-01 Projects list
LIB-02 Projects grid
LIB-03 Search
LIB-04 Sort/filter
LIB-05 Project details
LIB-06 Rename
LIB-07 Duplicate
LIB-08 Delete confirmation
LIB-09 Archive
LIB-10 Empty library
LIB-11 Missing/corrupt media

## Media import
MED-01 Source chooser
MED-02 Android media picker
MED-03 Selected media review
MED-04 Multi-select
MED-05 Media scanning
MED-06 Unsupported media
MED-07 Permission denied

## Thumbnails
TH-01 Loading
TH-02 Ready
TH-03 Generation failed
TH-04 Project cover
TH-05 Timeline strip
TH-06 Timeline loading
TH-07 Timeline fallback
TH-08 Template thumbnail
TH-09 Template loading
TH-10 Selected thumbnail
TH-11 Smart representative frame
TH-12 Cache rebuild

## Camera
CAM-01 Permission
CAM-02 Preview
CAM-03 Recording
CAM-04 Recording paused
CAM-05 Review
CAM-06 Retake confirmation
CAM-07 Camera unavailable
CAM-08 Camera settings

## Creation intent
CRT-01 What do you want to create?
CRT-02 Choose source
CRT-03 Choose template
CRT-04 Quick creation
CRT-05 Import project (future)

## Beginner editor
EDT-01 Editor loading
EDT-02 Beginner editor
EDT-03 Preview player
EDT-04 Contextual action bar
EDT-05 Trim
EDT-06 Split
EDT-07 Text
EDT-08 Subtitles
EDT-09 Music
EDT-10 Improve
EDT-11 Crop
EDT-12 Rotate
EDT-13 Speed
EDT-14 More controls
EDT-15 Undo/redo state
EDT-16 Autosave state

## Studio
STD-01 Studio entry
STD-02 Multi-track timeline
STD-03 Track inspector
STD-04 Clip inspector
STD-05 Text inspector
STD-06 Audio inspector
STD-07 Effects browser
STD-08 Transitions browser
STD-09 Keyframe editor
STD-10 Color controls
STD-11 Mask controls
STD-12 Blend controls

## Text
TXT-01 Add text
TXT-02 Text editor
TXT-03 Font selector
TXT-04 Text color
TXT-05 Position
TXT-06 Background
TXT-07 Animation
TXT-08 Saved text styles

## Subtitles
SUB-01 Method chooser
SUB-02 Manual subtitle editor
SUB-03 SRT import
SUB-04 Automatic caption processing
SUB-05 Caption review
SUB-06 Caption style
SUB-07 Caption timing editor
SUB-08 Caption error/recovery

## Audio
AUD-01 Audio browser
AUD-02 Music picker
AUD-03 Voice-over recorder
AUD-04 Volume
AUD-05 Fade
AUD-06 Audio enhancement
AUD-07 Noise reduction
AUD-08 Advanced audio

## Visual
VIS-01 Improve video
VIS-02 Brightness
VIS-03 Contrast
VIS-04 Saturation
VIS-05 Crop
VIS-06 Filters
VIS-07 Temperature/tint
VIS-08 Highlights/shadows
VIS-09 Curves
VIS-10 LUTs

## Templates
TMP-01 Template home
TMP-02 Category
TMP-03 Template details
TMP-04 Template preview
TMP-05 Use template
TMP-06 Customization
TMP-07 Saved templates
TMP-08 Premium templates

## AI/Jev
AI-01 Smart assistant
AI-02 Analyzing
AI-03 Recommendation summary
AI-04 Before/after
AI-05 Recommendation detail
AI-06 Low-confidence review
AI-07 AI unavailable/offline fallback
AI-08 AI privacy explanation

## Export
EXP-01 Destination
EXP-02 Recommended export
EXP-03 Advanced export
EXP-04 Resolution
EXP-05 Aspect ratio
EXP-06 FPS
EXP-07 Quality/size
EXP-08 Codec
EXP-09 HDR
EXP-10 Capability warning
EXP-11 Processing
EXP-12 Success
EXP-13 Failure
EXP-14 Low storage
EXP-15 Cancel confirmation
EXP-16 Share result

## Settings
SET-01 Settings
SET-02 Account
SET-03 Appearance
SET-04 Language
SET-05 Accessibility
SET-06 Storage
SET-07 Export defaults
SET-08 AI/privacy
SET-09 Downloads/assets
SET-10 Notifications
SET-11 Help/support
SET-12 About
SET-13 Open-source licenses
SET-14 Privacy policy
SET-15 Terms

## Global states
Every relevant screen must define:
loading, empty, success, error, offline, permission denied, disabled, processing, partial availability and recovery.

# Future Creative Studio Screens
These screens are planned for later phases and should not block the Android video MVP.

## Creative home
CRE-01 Creative Studio home
CRE-02 What do you want to create?
CRE-03 Describe your goal
CRE-04 Choose industry/domain
CRE-05 Choose audience
CRE-06 Choose tone/style
CRE-07 Creative brief review

## AI creative direction
DIR-01 Creative directions
DIR-02 Direction detail
DIR-03 Compare directions
DIR-04 Visual moodboard
DIR-05 Typography direction
DIR-06 Color direction
DIR-07 Composition direction
DIR-08 Regenerate direction

## Graphic design
GFX-01 Graphic Studio
GFX-02 Poster/flyer canvas
GFX-03 Social post canvas
GFX-04 Thumbnail canvas
GFX-05 Template browser
GFX-06 Template customization
GFX-07 Layout assistant
GFX-08 Typography assistant
GFX-09 Image replacement
GFX-10 Background generation/removal
GFX-11 Resize/adapt format
GFX-12 Brand check
GFX-13 Export variants

## Generative media
GEN-01 Generation workspace
GEN-02 Image generation
GEN-03 Image editing
GEN-04 Video generation
GEN-05 Video transformation
GEN-06 Audio/voice generation
GEN-07 Music/SFX generation
GEN-08 Generation queue
GEN-09 Generation result review
GEN-10 Generation failure/retry

## Story and campaign
STO-01 Scenario generator
STO-02 Script editor
STO-03 Storyboard
STO-04 Shot list
STO-05 Campaign planner
STO-06 Asset requirements
STO-07 Auto assembly
STO-08 Campaign variants

## AI roles
ROL-01 AI creative roles
ROL-02 Role detail
ROL-03 Role skills
ROL-04 Role instructions/prompt pack
ROL-05 Role constraints
ROL-06 Role evaluation criteria
ROL-07 Create custom role

## Brand and assets
BRD-01 Brand workspace
BRD-02 Brand kit
BRD-03 Logo manager
BRD-04 Color palette
BRD-05 Typography
BRD-06 Brand imagery
BRD-07 Voice/tone guide
BRD-08 Brand rules
AST-01 Asset library
AST-02 Asset search
AST-03 Asset collections
AST-04 Generated assets
AST-05 Asset provenance/details
AST-06 Favorites

## Quality and review
QAL-01 Design quality review
QAL-02 Readability check
QAL-03 Contrast/accessibility check
QAL-04 Layout consistency check
QAL-05 Brand consistency check
QAL-06 AI-generation disclosure/metadata where required

All future screens must define loading, empty, processing, error, offline/limited-provider, regeneration, cancellation and recovery states.
