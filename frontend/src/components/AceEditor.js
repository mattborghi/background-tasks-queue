import AceEditor from "react-ace";

import 'brace/mode/julia';
import 'brace/snippets/julia'
import 'brace/theme/github';
import "brace/ext/language_tools";
import "brace/ext/searchbox";

export function JuliaEditor({ code, setCode }) {

    return (
        <AceEditor
            placeholder="Write Julia Code"
            mode="julia"
            theme="github"
            name="blah2"
            onChange={e => setCode(e)}
            fontSize={14}
            showPrintMargin={true}
            showGutter={true}
            highlightActiveLine={true}
            value={code}
            setOptions={{
                enableBasicAutocompletion: true,
                enableLiveAutocompletion: true,
                enableSnippets: true,
                showLineNumbers: true,
                tabSize: 4,
            }} />
    )
}