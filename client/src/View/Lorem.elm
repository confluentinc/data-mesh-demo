module View.Lorem exposing (..)

import Html exposing (div, p, text)


lorem =
    div []
        [ lorem1
        , lorem2
        , lorem3
        ]


lorem1 =
    p [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quis velit pharetra, volutpat purus eu, faucibus turpis. Nullam sem erat, rutrum in velit et, sollicitudin fringilla turpis. Curabitur ultricies volutpat mi, quis tristique mi consequat vitae. Pellentesque in lorem vitae dui commodo sagittis ac quis mi. Nunc dignissim ipsum et vestibulum convallis. Donec velit mauris, pretium sit amet erat sit amet, pharetra tempor velit. Donec dictum mi nec aliquet ultricies. Quisque et velit iaculis, varius nunc ut, mollis dui. Donec et dapibus nisl. Quisque convallis pharetra condimentum. Vivamus eget pretium neque, vitae molestie dui. Pellentesque a efficitur libero, a aliquet ante. Curabitur aliquam, tellus sed interdum varius, orci ligula tincidunt diam, at placerat mauris nunc quis dui." ]


lorem2 =
    p [] [ text "Vestibulum tincidunt massa non elit vestibulum finibus. Sed elementum tristique augue, sed tristique justo facilisis eget. Phasellus nec molestie tellus. Phasellus suscipit erat turpis, ut dictum enim luctus vitae. Duis vitae placerat ipsum. Aenean scelerisque finibus ligula, at ultricies purus condimentum ac. Aenean in odio ut dui tempus sagittis a sit amet velit. Sed finibus diam id sem elementum, eget dignissim est tincidunt. Morbi in eleifend velit. Phasellus nec pretium neque." ]


lorem3 =
    p [] [ text "Praesent non consectetur velit, eu facilisis risus. Donec rhoncus neque sed dolor sollicitudin viverra. Sed semper lectus sit amet nulla consectetur suscipit. Nulla facilisi. Nulla vehicula pharetra eros, non bibendum lorem mollis sed. Aenean vulputate sapien id elit euismod consectetur. Sed aliquet sapien est, nec sollicitudin dui pharetra ornare. Nulla interdum aliquam justo, eget mattis ligula lacinia a." ]
