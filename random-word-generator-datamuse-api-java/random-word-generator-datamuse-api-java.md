I was building an [app](https://github.com/Dhiraj072/yrandom) to display random youtube videos. For the app, I needed an easy way to get a random english word. Suprisingly, finding an API which fits my requirements was harder than expected. Finally, I ended up writing my own [random word generator](https://github.com/Dhiraj072/random-word-generator) using [Datamuse API](https://www.datamuse.com/api/).

# Why I couldn't use existing options?
I analysed a bunch of APIs, and none of them suited my requirements
* [Wordnik](https://developer.wordnik.com/) - Rich API with lots of documentation, but they were taking more than 7 days to send me an API key unless I donated money.
* [WordsAPI](https://www.wordsapi.com/) - Sleak website with straightforward random word API. But the free plan allowed only 2500 requests per day, which is a bit too low in my opinion.
* [random-word-api](https://random-word-api.herokuapp.com) - [RazorSh4rk](https://github.com/RazorSh4rk/random-word-api) built and deployed this API to use for everyone. It's pretty good but it generates a "random" word by choosing from a static list of words. Due to this static structure, I believe the words may get repeated too frequently.
* [DataMuse API](https://www.datamuse.com/api/) - This was most promising with 100,000 free requests per day. 

Finally, I decided to write my own random word generator java library using the DataMuse word-search API.

# Writing my own random word generator
As explained before, [Datamuse API](https://www.datamuse.com/api/) was my best option. Sadly, instead of a random-word API they only had a word-search API. You make a REST API call to them with a <code>topics</code> parameter, and they send you back a list of words on those <code>topics</code>. So I wrote the [random word generator](https://github.com/Dhiraj072/random-word-generator) library which is just a wrapper around the Datamuse API. The library allows you to get a random word with a simple static method call as below
```java
RandomWordGenerator.getRandomWord()
```

Behind the scenes, a few things are going on: 
* We have a <code>RandomWordGenerator</code> class which holds the <code>randomWords</code> list in memory
* We have a <code>Topics</code> class which holds a static list of various topics
* During initialization, the <code>RandomWordGenerator</code> makes a HTTP request to DataMuse API with a random <code>Topic</code> to get the list of words
* When a user makes a call to <code>RandomWordGenerator.getRandomWord()</code>, it
  * initiates a HTTP request to DataMuse API to get the next list of words *in a separate thread*
  * returns a randomly chosen word from the current <code>randomWords</code> list stored in memory
* In case the HTTP request made above fails, system defaults to getting a random word from the <code>Topics</code> class itself. Something is better than nothing.

Note that the *in a separate thread* part is pretty important above. Instantiating the HTTP request to DataMuse API in a separate thread allows the <code>RandomWordGenerator.getRandomWord()</code> to be instantaneous as the call doesn't need to wait for the HTTP response to come back.

The above design achieves a few things:
* Every call to <code>RandomWordGenerator.getRandomWord()</code> is instantaneous, as we return the word from the <code>randomWords</code> list in memory. Probably better than most REST APIs.
* Randomness of the words is ensured over time as every call to <code>RandomWordGenerator.getRandomWord()</code> has the side-effect of updating the current <code>randomWords</code> list with words for a new random <code>Topic</code>
* Randomness of words is ensured for quick multiple calls to <code>RandomWordGenerator.getRandomWord()</code>, because for every call a random word is chosen from the <code>randomWords</code> list
* It's robust. If due to any reason the call to DataMuse API fails, then we fall back to the offline <code>Topics</code> class to get a random word.

In case you want to have a look at the source code, you will find it here. Please feel free to provide your suggestions / questions in comments!
{% github dhiraj072/random-word-generator %}
