![Don't forget your towel](doc_assets/towel.png?raw=true  "Don't forget your towel")
# TresWeb

> The Hitchhiker's Guide to the Dweb.

**TresWeb is a local-first tool to inspect, explore and understand the core properties over which the  modern decentralized web is made of**

[![TresWeb CI](https://github.com/spawnfest/tres-web/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/spawnfest/tres-web/actions/workflows/ci.yml)

## Table of Contents

1. [About](#about)
2. [Features](#features)
    - [CID Inspector](cid-inspector)
    - [IPFS File Explorer](ipfs-file-explorer)
    - [IPFS File Preview Mode](ipfs-file-preview-mode)
    - [Multiaddr Inspector](multiaddr-inspector)
3. [Running TresWeb](#running-tresweb)
    - [Prerequisites](#prerequisites)
4. [Roadmap](#roadmap)

## About

- TresWeb is a local-first web application to inspect, understand and explore the core properties on which modern decentralized web is made of.

- For example, one of the core properties is [`CID`](https://proto.school/content-addressing/03) (Self-describing content-addressed identifiers). [CIDs are fixed length](https://proto.school/anatomy-of-a-cid/01) and made up of multiple parts. Using `TresWeb`, we can breakdown the CID into its individual parts and get a deep insight on what it represents.

- Inlcuding CID breakdown, TresWeb comes with a set of features, that will help us to play with properties like CID, multiaddr, ipfs file-system etc.

- TresWeb itself can be used locally, and no need to host anywhere, but it can access and inspect content over the decentralized web.

## Features

### CID Inspector

- Decodes the given CID into its multiple parts
- Detailed info for each part
- Provides a Human readable version too
<!-- GIF -->

### IPFS File Explorer

- From a given CID, we can explore the content and content info
- We can traverse the directories and files in it, recursively

<!-- GIF -->

### IPFS File Preview Mode

- Preview mode is a part of file explorer
- With preview mode, we get far more insight into the files, without accessing it separately

<!-- GIF -->

### Multiaddr Inspector
- Inspects and interprets multiaddrs
- Render the encapsulation diagram for given multiaddr

<!-- GIF -->

## Running TresWeb

### Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)


## Roadmap
- Adding inspector ability to more Dweb properties/features, such as Filecoin, IPLD etc.
- Remove docker dependency, and make it as a purely standalone
## Credits

<div>TresWeb logo -  <a href="https://www.flaticon.com/free-icons/towel" title="towel icons">Towel icons created by smashingstocks - Flaticon</a>