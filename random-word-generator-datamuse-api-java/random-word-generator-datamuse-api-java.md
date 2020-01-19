I was building an [app](https://github.com/Dhiraj072/yrandom) to display random youtube videos. For the app, I needed an easy way to get a random english word. Suprisingly, finding an API which does this was harder than expected. Finally, I ended up writing my own random word generator using the word-search [Datamuse API](https://www.datamuse.com/api/).

# Analysing available random word APIs
I analysed a bunch of APIs, and none of the following suited my requirements
* [Wordnik](https://developer.wordnik.com/) - Rich API with lots of documentation, but they were taking more than 7 days to send me an API key unless I donated money.
* [WordsAPI](https://www.wordsapi.com/) - Sleak website with a random-word API. But the free plan  allowed only 2500 requests per day, which was a bit too low in my opinion.
* [random-word-api](https://random-word-api.herokuapp.com) - [RazorSh4rk](https://github.com/RazorSh4rk/random-word-api) built and deployed this API to use everyone. It's pretty good but it generates a "random" word by choosing from a static list of words. Due to this static structure, I believe the words may get repeated too frequently.
* [DataMuse](https://www.datamuse.com/api/) - This was most promising with 100,000 free requests per day. But sadly, instead of a random-word API they had a word-search API.

Finally, I decided to build a random word generator using the DataMuse word-search API.

#

