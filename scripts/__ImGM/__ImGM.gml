// TODO: Documentaion
function __ImGM(){
    static VERSION = IMGM_VERSION;
    static base_x = 0;
    static base_y = 0;

    static __Utils = function __ImGM_Utils() constructor {
        /**
         * @function __imgm_update_imgui_base_pos
         * @description
         * @context ImGM
         */
        static __imgm_update_imgui_base_pos = function() {
            // Base coordinates depend on the chosen renderer:
            if (ImGui.__GFlags & ImGuiGFlags.GM == 0) {
                // - Base position is relative to the Game window if using the GM Renderer.
                __ImGM.base_x = window_get_x();
                __ImGM.base_y = window_get_y();
            } else {
                // - Otherwise, base position is a discarded offset.
                __ImGM.base_x = 0;
                __ImGM.base_y = 0;
            }
        }
        static Update = function() {
            if (ImGui.__GFlags & ImGuiGFlags.GM == 0) {
                __imgm_update_imgui_base_pos();
            }
        }
    };
    static Utils = new __Utils();

    static _all = static_get(__ImGM);
    return _all;
}