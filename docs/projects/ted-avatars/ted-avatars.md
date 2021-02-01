https://fun.redopop.com/avatars/



Since 2017 I've worked for TED Conferences.

In 2019, TED began a project to replace its default avatar, a gray silhouette,
with a range of more interesting images that better reflected TED's brand.

# Goal

The goal was what I'd guess most generative-avatar projects aim for: to improve
the look of pages with lots of avatars, but without being so interesting that
people preferred their generated avatar to their photo.

The goal was what I'd guess most generative-avatar projects aim for: to improve
the look of pages with lots of avatars, but not so much that people preferred
their generated avatar to their photo.

Ideally, everyone would upload a photo (or some kind of image that represented
them), but until then, we wanted something more vibrant than a sea of gray
silhouettes. 

to make images that were interesting, but not as interesting as a human face

The goal was to be interesting, but not _too_ interesting.

> Goal: To create a cohesive set of avatars which will be assigned to users who
> do not upload a profile photo, in order to aesthetically elevate our
> community experiences and encourage profile completion.
> 
> Avatars should be distinct enough to be differentiated at a small scale (40px
> square), while still maintaining the consistency of the TED.com brand
> 
> Avatars should be visually interesting, but not so much that they dissuade
> users from uploading their own photos
> 
> Avatars should be colorful in order to add personality to our community
> experiences
> 
> Avatar content should be abstract so that they are universally relatable

# Constraints

The images needed to be stable: if you don't always see the same image for a
person, it's not much of an avatar. We could solve this by generating images
randomly and storing them, or by using a deterministic algorithm over profile
data; I believe we opted for the latter because it's much cheaper and simpler.

The only field we had for every TED profile on record was the timestamp of when
the person signed up. (New sign-ups don't have to specify a name, and some
profiles created through other systems don't have an email address.) This
narrow constraint was as freeing as [common wisdom
suggests](https://duckduckgo.com/?q=constraints+are+liberating), and informed
the initial design: [Tara Lynn Connelly](http://www.taralynnconnelly.com)
created 24 proof-of-concept images, one for each hour of the day, in AM and PM
variants, combining the hour number (1-12) in Helvetica (TED's logo typeface)
with an organic shape and a red dot (for TED's red speaker circle).

The next step was to scale it so that any two profiles on the same page had
much less than a 1-in-24 chance of having the same avatar.

Given a page showing with 30 profile avatars, and assuming half of them have a
generated avatar, [the probability that no two of the 15 have the same
avatar](https://en.wikipedia.org/wiki/Birthday_problem) is:

    1 - (24/24 * 23/24 * 22/24 * ... * 10/24)

...which comes out to 0.996613321180896, or 99.7%. Any random set of avatars
will have a collision all but 3 times in a thousand.



    def birthday(pigeons, boxes)
      1.0 - boxes.downto(boxes-(pigeons-1)).map {
        |n| n / boxes.to_f
      }.reduce(:*)
    end


One constraint we discovered only once we'd been in development for a while was
that the images should not change too gradually, second-to-second or
minute-to-minute. Since ted.com/people used to let you sort profiles by when
they were created, and the creation date was the only input to the algorithm,
if the algorithm varied its output too little, that page would show a bunch of
avatars that had only minimal variation -- it wasn't enough that they be
different, they had to be obviously different. 



# Approach

Tara asked her teammates [Joe Bartlett](https://redopop.com) and me for help.

Joe's expertise in front-end web development was invaluable, since the primary
target platform was ted.com. He suggested we generate SVGs, so the output would
be crisp at any resolution and dimension, and always have a tiny filesize. (A
random example I just picked weighs only 1.37 KB.)

Rather than expressing calculations in code, we generated SVGs via text
templates. Tara already grasped the kinds of variations she wanted, and we were
able to express that as a set of string interpolations with some logic
transforming the input date into colors, radii, opacities, rotations, etc, as
needed; the organic shapes and Helvetica number shapes were stored in an array
of path coordinates, and the input date also became an index into it.

This made the SVG generation process and its code very legible ("how does this
number become that SVG?"), even if it obscured the logic of the generative
algorithm ("WHY does this number become that SVG?").






# After

<How do I tell this part of the story? ...DO I tell it?>
<Do I tell the SVG-to-PNG part of the story? The React part?>
