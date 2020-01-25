---
cover_image: https://live.staticflickr.com/94/238065414_437b1e1cf0_b.jpg
---
I was building an [app](https://github.com/Dhiraj072/yrandom) to display random youtube videos. For the app, I needed an easy way to get a random english word. Suprisingly, finding an API which fit my requirements was harder than I expected. Finally, I ended up writing my own [random word generator](https://github.com/Dhiraj072/random-word-generator) using [Datamuse API](https://www.datamuse.com/api/).

# Why I couldn't use existing options?
I analysed a bunch of APIs, and none of them suited my requirements
* [Wordnik](https://developer.wordnik.com/) - Rich API with lots of documentation, but they were taking more than 7 days to send me an API key unless I donated money.
* [WordsAPI](https://www.wordsapi.com/) - Sleak website with straightforward random word API, but the free plan allowed only 2500 requests per day, which is a bit too low in my opinion.
* [random-word-api](https://random-word-api.herokuapp.com) - Pretty good except that it generates a "random" word by choosing from a static list of words, which may result in words getting repeated frequently.
* [DataMuse API](https://www.datamuse.com/api/) - This was most promising with 100,000 free requests per day, though they didn't have a straightforward random word api. 

Finally, I decided to write my own [random word generator](https://github.com/Dhiraj072/random-word-generator) java library using the DataMuse word-search API.

# Writing my own random word generator
As explained before, [Datamuse API](https://www.datamuse.com/api/) was my best option. Sadly, instead of a random-word API they only had a [word-search](http://www.datamuse.com/api/) API. You make a REST API call to them with a <code>topics</code> parameter, and they send you back a list of words on those <code>topics</code>. The [random word generator](https://github.com/Dhiraj072/random-word-generator) library which is just a wrapper around the Datamuse API. The library allows you to get a random word with a simple static method call as below
```java
// Import the class
import com.github.dhiraj072.randomwordgenerator.RandomWordGenerator;

// A simple static method call to get the random word
String randomWord = RandomWordGenerator.getRandomWord()
```

Behind the scenes, a few things are going on: 
* We have
 * <code>RandomWordGenerator</code> class which holds a list of words(<code>randomWords</code>) in memory
 * <code>Topics</code> class which holds a static list of various topics e.g. acting, chess, etc.
* During initialization, <code>RandomWordGenerator</code> makes an HTTP request to DataMuse API with a random <code>Topic</code> and updates <code>randomWords</code> value with the list of words returned by the API
* When a user makes a call to <code>RandomWordGenerator.getRandomWord()</code>
  *  an HTTP request to DataMuse API is initiated to get the next list of words *in a separate thread*
  *  a randomly chosen word from the <code>randomWords</code> list is returned 
* In case the HTTP request made above fails, system defaults to getting a random word from the <code>Topics</code> class itself. Something is better than nothing.

Note that *in a separate thread* part is pretty important above. Instantiating the HTTP request to DataMuse API in a separate thread allows the <code>RandomWordGenerator.getRandomWord()</code>  call to be instantaneous as it doesn't need to wait for the HTTP response to come back.

The above design achieves a few things:
* **Every call to <code>RandomWordGenerator.getRandomWord()</code> is instantaneous** since we return the word from the <code>randomWords</code> list already present in memory. I believe this is better than most/all REST APIs as there is no overhead of an HTTP request.
* **Randomness of the words is ensured over time** as every call to <code>RandomWordGenerator.getRandomWord()</code> has the side-effect of updating the current <code>randomWords</code> list with words for a new random <code>Topic</code>
* **Randomness of words is ensured for quick multiple calls** to <code>RandomWordGenerator.getRandomWord()</code>, because for every call a random word is chosen from the <code>randomWords</code> list
* **It's robust.** If due to any reason the call to DataMuse API fails, then we fall back to the offline <code>Topics</code> class to get a random word.

In case you want to have a look at the source code or use this library in your own project, the link is below. Please feel free to post your suggestions/questions in comments!
{% github dhiraj072/random-word-generator %}
