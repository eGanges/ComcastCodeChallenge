# ComcastCodeChallenge

This project was submitted as part of a job application coding challenge for Comcast Cable, in Philadelphia Pa. 

This repository is for code review purposes only.

Please see /Documentation/NOTES.pdf for full details of this projects implementation, architeture, coding, and architectural decisions.  Architecture, coding, design (UI/UX), documentation, and additional graphics arts (icons, launch screens, image choices, etc) by Edward Ganges.

Copyright © 2019 Edward C Ganges. All rights reserved.

-----------------

Challenge Overiew:

Write a sample app that fetches and displays data from a RESTful Web API.
The app should be able to display the data as a text only, scrollable list of titles, and on phones, should be toggle- able from the list to a scrollable grid of item images. The title and description for each item should each be parsed out of the data in the "Text" field. Images should be loaded from the URLs in the "Icon" field. For items with blank or missing image URLs, use a placeholder image of your choice.

Clicking on an item should load a Detail view, including the item’s image, title, and description. You choose the layout of the Detail view. On tablets, the app should show the list and detail views on the same screen. For phones, the list and detail should each be full screen. The app should have an tool-bar that displays:

For Phone - The name of the app on the item list screen, and the title of the item on the detail screen
For Tablets - The name of the app

In addition, two versions of the app should be created. Each version has a different Name, package-name, and url that it pulls data from. interested in your methodology for creating multiple apps from a shared codebase).

As a bonus, implement one of the following (not required):

1. Local search functionality that filters the item list according to items whose titles or descriptions contain the query text

2. Functionality to favorite characters, and a drawer layout for navigating between a view of all characters, and a view of only favorited items

3. Animated transitions between the item list and detail screen (for phones), or animated detail-pane loading on tablets. You choose the complexity and character of the animations.
