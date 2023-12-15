# Invasive Plants App User Guide

This Invasive Plants App currently allows users to identify invasive plants in two Canadian provinces: British Columbia and Ontario, and suggests alternative non-invasive plants to plant instead.

| Index                                         | Description                                                                            |
| :-------------------------------------------- | :------------------------------------------------------------------------------------- |
| [Log in and Sign up](#log-in-and-sign-up)     | User log in or sign up to the app                                                      |
| [Home Page](#home-page)                       | Setting user location and searching invasive species                                   |
| [Plant Identification](#plant-identification) | Taking/uploading photos, navigating plant matches, and understanding plant information |
| [Lists](#lists)                               | Creating and saving plants into lists                                                  |

## Log in and Sign up

Upon loading the app, it will request access to the user's location. This information is used to identify whether a plant is invasive or not in the user's specified location. Users can also choose to manually adjust their location at any time.

Next, the user can log in or sign up with their email. Signing up is only required if the user intends to save plants into custom [lists](#lists). Otherwise, the user can opt to `Continue as Guest`, which grants access to all other features without registration.
![sign up page](TODO)

## Home Page

After logging in or continuing as guest, the user will be directed to the Home Page. This page displays all of the invasive plants that fall within the selected region, which the user has the option to change. The app currently supports invasive plants in British Columbia and Ontario. The user can scroll through and browse these plants or search up a specific invasive plant by scientific name.
![home page](TODO)

### Profile Icon

Located at the top left corner of the Home Page, a profile icon can be clicked. If the user is already signed in, they will have the option to sign out or delete their account. Otherwise, clicking on this icon redirect the user to [log in or sign up](#log-in-and-sign-up) page.
![sign out and delete account dialog](TODO)

### Navbar

Each page features a bottom navigation bar with three icons. The home icon brings the user to the [Home Page](#home-page), the camera icon to the [camera](#camera), and the save icon to the user's [lists](#lists).
![navbar](TODO)

## Plant Identification

The following section will explain how a user can identify an invasive plant and follow-up measures to take.

### Camera

The user can either take a photo of a plant or upload an existing photo for identification.
![camera](TODO)

Next, the user can select the part of the plant they've photographed, choosing from the following plant organs:

- leaf
- flower
- fruit
- bark
  ![select plant organ](TODO)

Clicking on the `Find Matches` button will show which plants are the [best matches](#plant-matches).

### Plant matches

If no matches are found, the user will be prompted to retake or reupload a photo.
![no match](TODO)

Otherwise, the user will be provided with previews of the best 3 matches. Matches are marked as invasive or non-invasive given the user's location. Each match preview will provide the plant's scientific name(s) and common name(s), a similarity score, a plant image, and the option to [learn more](#plant-info) about the plant.

![match non-invasive](TODO)
![match invasive](TODO)

### Plant info

After clicking into a plant, the user will be provided with detailed information, such as a description and images. If the plant is invasive, there will be an `Alternatives` tab providing a list of similar non-invasive species to plant instead. At the bottom of each page, users can find links to external sources providing further information on the plant if desired.
![plant information](TODO)

Additionally, the user can choose to save the plant to a [list](#lists) by clicking on the save icon next to the plant's name.
![save plant](TODO)

## Lists
To access the lists feature, users are required to be [logged in](#log-in-and-sign-up). This functionality allows users to create personalized plant lists for better organization and convenient future access of plant information.
![all lists](TODO)
![specific list example](TODO)
