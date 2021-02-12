import { Light as SyntaxHighlighter } from 'react-syntax-highlighter';
import julia from 'react-syntax-highlighter/dist/esm/languages/hljs/julia';
import github from 'react-syntax-highlighter/dist/esm/styles/hljs/github';

SyntaxHighlighter.registerLanguage('julia', julia);

export const PreviewCode = ({ code }) => {
    return (
        <SyntaxHighlighter language="julia" style={github} showLineNumbers wrapLines>
            {code}
        </SyntaxHighlighter>
    );
};