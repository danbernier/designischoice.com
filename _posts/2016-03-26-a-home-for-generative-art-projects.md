---
title: A Home for Generative Art Projects
date: 2016-04-01
---

For over a decade (yeesh), I've intermittently blogged at [invisibleblocks](http://invisibleblocks.com) about software, agile methods, amateur math, and programming languages, but in the past few years, generative art posts have appeared in the mix. This new tangent threatens to unravel that blog's argument, and ruin my reputation as a sober software engineer. 

So I'm moving it here.

Besides, the unit of generative art is the project, and a project needs a home. Projects move more slowly than thoughts. You can spit out a thought, and no one notices if you got it wrong, because they still have five more things to read before the _next_ wave of stuff, and your thought is forgotten. Projects move more slowly. A steady URL can be a good home.

## Design is Choice: About the Name

If you read books or essays about product design, you'll find the idea that design is about choosing one solution from all possible solutions, a range of solutions, or a "solution space." Each solution comes with its own trade-offs: things it does well, and things it does poorly. A well-designed product has a good match between what it's supposed to do, and what it does well. 

This also applies to software design: the way the internals are organized and shaped. To choose a good abstraction, you have to know what the software needs to do, know several ways of doing that, and examine the trade-offs.

Back to generative art. Let's look at probably the least-interesting bit of generative art ever made: a white dot, randomly positioned on a black field.

<div id='sketchHolder' class='box-shadow'></div>
<script id='sketchSource'>
function setup() {
  createCanvas(200, 200);
  $('#sketchHolder').append($('#defaultCanvas0'));
}
function draw() {
  background(0);
  var x = random(width);
  var y = random(height);
  fill(255);
  ellipse(x, y, 15, 15);
  noLoop();
}
function mouseClicked() {
  loop();
}
</script>

Click to make another one. Go on, knock yourself out.

The program that makes these beauties chooses where the dot should go. It chooses randomly, but it could choose in lots of ways: it could place it according to the time of day, the stock price of some company, the temperature in Buenos Aires. But it _chooses._

The dot will be centered on one of 200 horizontal pixels, and one of 200 vertical pixels, meaning that each image is one in 200&times;200, or one in 40000. Which of these 40,000 images is interesting?

![](/images/{{ page.dir }}/five-white.png)

Let's randomize the color of the dot. 

![](/images/{{ page.dir }}/five-colors.png)

Now, for every possible placement of the dot, there are 255&times;255&times;255 possible images.[^rgb] That brings the total number of images to 200&times;200&times;255&times;255&times;255 = 663.255 billion. Not bad! 

[^rgb]: Computers make different colors by blending various amounts of red, green, and blue light, and generally allow for 255 levels of redness, 255 levels of green-ness, and 255 levels of blue-ness.

What if we also randomly change the background color? 

![](/images/{{ page.dir }}/five-bg-colors.png)

Multiply in another 255&times;255&times;255, for 10,997,679,875,625,000,000, which is almost eleven quintillion. Which of _those_ is interesting?

On second thought, let's not vary the background color. The black background is nice, and we probably won't see enough of the eleven quintillion to find the good ones.

The algorithm chooses the specifics - where the dot should go, which color it should be. We choose which outcomes we like. But we also choose the range of possibilities, because we _write_ the algorithm. If a particular elaboration introduces more bad outcomes than good, we can take it out, and shrink the solution space. 

The generative artist chooses the algorithm, the algorithm chooses the particulars, and the artist chooses the outputs. If the algorithm is interactive, and the artist can steer it somehow, the algorithm and the artist can choose together.

Generative art, algorithmic art, sounds inhuman, sounds automatic. But an algorithm can engender an unimaginable number of outcomes. The line between noise and art is in how we choose.
