defmodule Casus do
  @moduledoc """
  Casus is a CQRS/ES toolkit for elixir applications.

  Explicit some nice things here.

    - How Aggregate works
    - What is the Domain package and what it means
    - What are the Infra

  There should be an explanation about how to configure the domain to be used by the Aggregate module.
  In particular :
    - the Casus.Domain.RootAggregate protocol
    - the Casus.Domain.Event protocol
    - the Casus.Infra.EventNameTypeProvider behaviour

  Explicit the Event_Bus behaviour
  Explicit the Event_Store behaviour

  ## Event Sourcing

  ### What is event sourcing ?

  Event sourcing is the principle that the state of an entity can be represented by a series of events.

  **Example:**

  - Blog post was initialized by user 1
  - Blog post was modified by user 1
  - Blog post was published by user 1
  - Blog post was read by user 2
  - Blog post was read by user 3

  It
  ### What does it mean for your code ?

  ## How to use Casus ?

  ### Casus philosophy

  Casus is thought to be part of your clean architecture (or onion architecture).
  In that sense it is a part of the infrastructure layer. Your business logic is going to be part of the domain central
  layer. And to make your business logic usable by the Casus library, some adapters have to be written - each one of
  them being a protocol implementation.

  ### Architecture diagram
  It is worth what it is worth, but it should give you insights on how Casus is expected to be used.

  Arrows are "what concept knows about/depends on which other concept"
  ```txt
  *-------------------------------------------------------------------*
  |APPLICATION                                                        |
  |  *-------------------*               *------------------*         |
  |  |                   |               | USECASE.COMMAND  |         |
  |  |  HTTP CONTROLLER  |-------------->|     Adapter      |         |
  |  |                   |               |                  |         |
  |  *-------------------*               *------------------*         |
  |            |                                   |                  |
  +------------+-----------------------------------+------------------+
               |                                   |
  *------------+-----------------------------------+------------------*
  |USECASE     v                                   v                  |
  | *--------------------*             *----------------------*       |
  | |  USECASE.COMMAND   |             |   USECASE.COMMAND    |       |
  | |      Handler       |------------>|     data-object      |       |
  | |                    |             |                      |       |
  | *--------------------*             *----------------------*       |
  |            |                                                      |    *------------------------------*
  |            |                                                      |    |DOMAIN                        |
  |            v              *---------------------------------------+--* |                              |
  | *--------------------*    |                                       |  | | *--------------------------* |
  | |                    |    |         *-------------------------*   |  | | |DOMAIN.AGGREGATE          | |
  | |  USECASE.COMMAND   |    |         |CASUS.ADAPTER            |   |  | | |  *---------------------* | |
  | |  execution logic   |----+         | *---------------------* |   |  +-+-+->|   DOMAIN.COMMAND    | | |
  | |                    |              | |    Impl protocol    | |   |  | | |  *---------------------* | |
  | *--------------------*           *--+-|  CASUS.DOMAIN.ROOT  |-+---+* +-+-+->*---------------------* | |
  |            |                     |  | |  FOR AGGREGATE_ID   | |   ||   | |  | DOMAIN.AGGREGATE_ID | | |
  |            |                     |  | *---------------------* |   |+---+-+->*---------------------* | |
  |            |                     |  | *---------------------* |   |    | |  *---------------------* | |
  |            |                     |  | |    Impl protocol    | |   | *--+-+->|    DOMAIN.EVENT     | | |
  |            |                     | *+-| CASUS.DOMAIN.EVENT  |-+---+-+  | |  *---------------------* | |
  |            +-----*               | || |  FOR DOMAIN.EVENT   | |   |    | *--------------------------* |
  |                  |               | || *---------------------* |   |    +------------------------------+
  |                  |               | |*-------------------------*   |
  +------------------+---------------+-+------------------------------+
                     |               | +----------------------*
  *------------------+---------------+------------------------+-------*
  |CASUS             v               |                        v       |
  |        *------------------*      +-->*-----------* *------------* |
  |        |    AGGREGATE     |--+-*     | protocol  | |  protocol  | |
  |        *------------------*  | +---->|DOMAIN.ROOT| |DOMAIN.EVENT| |
  |        *------------------*  | |     *-----------* *------------* |
  |     *--|   EVENT_STORE    |<-+ |                          ^       |
  |     |  *------------------*    +--------------------------+       |
  |     |  *------------------*                                       |
  |     +->|    EVENT_BUS     |                                       |
  |        *------------------*                                       |
  +-------------------------------------------------------------------+
  ```
  """

  @doc """
  Hello world.

  ## Examples

      iex> Casus.hello()
      :world

  """
  def hello do
    :world
  end
end
