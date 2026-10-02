# 05 — User Flows

## First launch
```mermaid
flowchart TD
A[First launch] --> B[Welcome]
B --> C[Language]
C --> D[Privacy explanation]
D --> E[Permissions]
E --> F[Home]
F --> G[Create first video]
```

## First successful video
```mermaid
flowchart TD
A[Home] --> B[Create]
B --> C[Choose video]
C --> D[Preview]
D --> E{What do you want?}
E -->|Make it better| F[Improve]
E -->|Make it shorter| G[Trim]
E -->|Add words| H[Text]
E -->|Add subtitles| I[Captions]
F --> J[Preview]
G --> J
H --> J
I --> J
J --> K[Save]
K --> L[Share]
```

## Import
```mermaid
flowchart TD
A[Create] --> B[Gallery]
B --> C[Media picker]
C --> D[Selected media]
D --> E[Metadata scan]
E --> F[Thumbnail generation]
F --> G[Project]
```

## Camera
```mermaid
flowchart TD
A[Create] --> B[Camera]
B --> C[Permissions]
C --> D[Preview]
D --> E[Record]
E --> F[Review]
F -->|Retake| D
F -->|Use| G[Project]
```

## AI improvement
```mermaid
flowchart TD
A[Video] --> B[Local analysis]
B --> C[Structured state]
C --> D[Jev]
D --> E[Recommendation]
E --> F[Deterministic edit engine]
F --> G[Preview]
G --> H{Accept?}
H -->|No| I[Undo/Adjust]
H -->|Yes| J[Project state]
```

## Export
```mermaid
flowchart TD
A[Editor] --> B[Save/Share]
B --> C[Destination]
C --> D[Recommended profile]
D --> E[Capability check]
E --> F{Supported?}
F -->|Yes| G[Export]
F -->|No| H[Fallback recommendation]
H --> G
G --> I[Progress]
I --> J[Success]
J --> K[Share/Save]
```

## Template
```mermaid
flowchart TD
A[Create] --> B[Templates]
B --> C[Category]
C --> D[Preview]
D --> E[Use]
E --> F[Select media]
F --> G[Recipe applied]
G --> H[Customize]
H --> I[Export]
```

## Offline
```mermaid
flowchart TD
A[Edit] --> B{Internet?}
B -->|Yes| C[Local editing + optional Jev]
B -->|No| D[Local editing + deterministic fallback]
C --> E[Export]
D --> E
```

## Future automatic short
```mermaid
flowchart TD
A[Long video] --> B[Audio extraction]
B --> C[Transcription]
C --> D[Segment analysis]
D --> E[Structured state]
E --> F[Jev]
F --> G[Candidate highlights]
G --> H[User review]
H --> I[Auto layout + captions]
I --> J[Export]
```

# Future Creative Studio Flows

## Poster from a simple request
```mermaid
flowchart TD
A[User: create a professional poster] --> B[Creative brief]
B --> C[Domain + audience]
C --> D[Creative directions]
D --> E{Template suitable?}
E -->|Yes| F[Recommend editable templates]
E -->|No| G[Generate visual direction]
F --> H[Compose]
G --> H
H --> I[Quality checks]
I --> J[User refinement]
J --> K[Export variants]
```

## Story to finished campaign
```mermaid
flowchart TD
A[Idea] --> B[Scenario/script]
B --> C[Storyboard]
C --> D[Shot list + asset plan]
D --> E[Generate/import media]
E --> F[Assemble video]
F --> G[Captions + audio + graphics]
G --> H[Thumbnail + poster + social variants]
H --> I[Quality review]
I --> J[Export/publish]
```

## AI creative team
```mermaid
flowchart LR
A[User brief] --> B[Creative Director]
B --> C[Art Director]
B --> D[Copywriter]
C --> E[Graphic/Video Designer]
D --> E
E --> F[Quality Reviewer]
F -->|Revision| E
F -->|Approved| G[Final outputs]
```
