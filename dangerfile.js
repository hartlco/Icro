import {danger, fail, message, warn} from 'danger'

  
// No PR is too small to include a description of why you made a change
if (danger.github.pr.body.length < 10) {
  warn('Please include a description of your PR changes.');
}

// Add a CHANGELOG entry for app changes
const hasChangelog = danger.git.modified_files.includes("CHANGELOG.yml")
const isTrivial = danger.github.pr.body.includes("#trivial")

if (!hasChangelog && !isTrivial) {
  warn("Please add a changelog entry for your changes.")
} 