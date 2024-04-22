# SrcCat

```bash
 _._     _,-'""`-._
 (,-.`._,'(       |\`-/|
     `-.-' \ )-`( , o o) 
           `-    \`_`"'-
```

A simple script that downloads a github repository and grabs all the text files of a given directory, recursively.

This is a helper script meant to concatenate code docs[^1] into a single file for ingestion into an LLM, with XML tags surrounding the source for [better understanding via Claude 3 Opus](https://docs.anthropic.com/claude/docs/long-context-window-tips#structuring-long-documents).

[^1]: Not tested with actual code yet, just documentation.

### Usage

Download the script (or create a new one locally and copy paste into it) and run it:

```bash
$ ./src-cat.sh 
# paste in a github url, which can be deeplinked to a folder of docs
$ Enter the GitHub repository URL: https://github.com/wevm/frog/tree/main/site/pages
# SrcCat will generate a filename based on the given path and name of the repo 
$ Enter the output file name (default: frog-site-pages.txt): 

$ Concatenation complete. Output file: frog-site-pages.txt
```

The repo is deleted from your /tmp directory and the newly created file can be used with Claude or your favorite LLM.

### Issues
Doesn't seem to play nicely with user/branch urls, so stick to main for now

### Why?
This was built to test the capabilities of large context models understanding code documentation to generate new code based on those docs.

Here's an example with Claude 3 Opus, based on the above github repo, to generate a new simple Frame from the [docs for Frog](https://github.com/wevm/frog/tree/main/site/pages):


First, upload the generated text file to Claude

Then add your prompt:
```
You are an expert in modern javascript and typescript for frontend and backend development. Using the attached documentation for the Frog UI Library for Farcaster Frames, generate a Frame with the following features:

1. The initial frame should be a dynamically generated image with the text "Welcome to Makerspace!". It should include 3 buttons: "Latest", "Random", and "Make your own"
2 .The Latest button should hit the "/latest" endpoint and generate a new frame, pulling from a service endpoint that gets the latest posts on makerspace. This backend code can be stubbed out.
3. The Random button does the same as latest but gets a random post
4. The "Make your own" will link out to a separate website, URL yet to be determined"
5. Both the Latest and Random return similar Frame content. They should include the first image of a project with "<<" and ">>" buttons that will cycle through the images of that project, returning whatever is given from the backend code for that specific project page

Think through how you might accomplish this task, making sure to use the documentation where necessary. Link to specific pages of the documentation when available in its <path> tag. Feel free to break up the individual frame generation code into its own files, ie a file for Latest and a file for Random.

# Taken from 
Before answering the question, please think about it step-by-step within <thinking></thinking> tags. Then, provide your final answer within <answer></answer> tags.
```

Claude does a decent job with these instructions, giving us the following output, even with paths to the documents where it found the answers:

```
Here is my thought process and proposed code to generate this Farcaster Frame experience:
<thinking>
1. Create a UI system using `createSystem` from 'frog/ui'. We can use the default color variables for now. Export the necessary UI components like Box, Heading, Button, Image, HStack.
<path>site/pages/ui/createSystem.mdx</path>
<path>site/pages/ui/Box.mdx</path>
<path>site/pages/ui/Heading.mdx</path>
<path>site/pages/ui/Image.mdx</path>
<path>site/pages/ui/HStack.mdx</path>

2. Create the initial `/` frame in index.tsx. Use Box and Heading UI components to layout the text "Welcome to Makerspace!". Add 3 buttons for "Latest", "Random", and "Make your own" using the Button intent.
<path>site/pages/intents/button.mdx</path>

3. For the "Latest" button, set the `action` prop to "/latest". Create a new `/latest` frame handler that calls a backend API (stubbed for now) to get the latest posts, and renders them in a new frame. 
<path>site/pages/concepts/actions.mdx</path>

4. For the "Random" button, do the same as "Latest" but set the `action` to "/random" and have the backend return a random post.

5. For the "Make your own" button, use `<Button.Link>` and set the `href` prop to the external URL.
<path>site/pages/intents/button-link.mdx</path>

6. In the `/latest` and `/random` frame handlers, destructure the post data from the backend response. Use the Image component to render the first project image. Add "<<" and ">>" buttons that will POST back to the same frame handler with an `imageIndex` in the body to cycle through the project images.

7. To keep track of the current `imageIndex`, use `deriveState` in the `/latest` and `/random` frame handlers. Increment/decrement the index when the "<<" or ">>" buttons are clicked, and pass the current image URL to the Image component.
<path>site/pages/concepts/state-management.mdx</path>

</thinking>

<answer>
```

```tsx twoslash [src/index.tsx]
// @noErrors
/** @jsxImportSource frog/jsx */
import { Frog } from 'frog'
import { createSystem } from 'frog/ui'

const { Box, Button, Heading, Image, HStack } = createSystem()

type State = {
  latestImageIndex: number
  randomImageIndex: number
}

export const app = new Frog<{ State: State }>({
  initialState: {
    latestImageIndex: 0,
    randomImageIndex: 0
  }
})

app.frame('/', (c) => {
  return c.res({
    image: (
      <Box padding="32">
        <Heading>Welcome to Makerspace!</Heading>
      </Box>
    ),
    intents: [
      <Button action="/latest">Latest</Button>,
      <Button action="/random">Random</Button>,
      <Button.Link href="https://example.com">Make your own</Button.Link>,
    ]
  })
})

app.frame('/latest', async (c) => {
  const { deriveState } = c
  const state = deriveState(prev => {
    if (c.buttonValue === '<<') prev.latestImageIndex = Math.max(0, prev.latestImageIndex - 1)
    if (c.buttonValue === '>>') prev.latestImageIndex = prev.latestImageIndex + 1
  })

  // Stub out backend call for latest projects data
  const latestProjects = await getLatestProjects()
  const project = latestProjects[0]

  return c.res({ 
    image: (
      <Box padding="32">
        <Image src={project.images[state.latestImageIndex]} />
      </Box>
    ),
    intents: [
      <Button value="<<">Previous</Button>,
      <Button value=">>">Next</Button>  
    ]
  })
})

app.frame('/random', async (c) => {
  const { deriveState } = c
  const state = deriveState(prev => {
    if (c.buttonValue === '<<') prev.randomImageIndex = Math.max(0, prev.randomImageIndex - 1) 
    if (c.buttonValue === '>>') prev.randomImageIndex = prev.randomImageIndex + 1
  })
  
  // Stub out backend call for random project data
  const randomProject = await getRandomProject()
  
  return c.res({
    image: (
      <Box padding="32"> 
        <Image src={randomProject.images[state.randomImageIndex]} />
      </Box>
    ),
    intents: [
      <Button value="<<">Previous</Button>,
      <Button value=">>">Next</Button>
    ]
  })
})

// Stub backend functions
async function getLatestProjects() {
  return [
    { 
      images: [
        'https://example.com/image1.png',
        'https://example.com/image2.png'
      ]
    }
  ]
}

async function getRandomProject() {
  return { 
    images: [
      'https://example.com/random1.png',
      'https://example.com/random2.png'  
    ]
  }
}
```

</answer>
```

Following up with `now that i have a working frame, how can i test it locally?` gets Claude to output code and answers for using the Frog dev tools, also documented in the initially created docs by SrcCat. 

